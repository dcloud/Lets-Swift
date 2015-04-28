//: # Parser Combinators


import Foundation


extension String {
    public var characters: [Character] {
        var result: [Character] = []
        for c in self {
            result += [c]
        }
        return result
    }
    public var slice: ArraySlice<Character> {
        let res = self.characters
        return res[0..<res.count]
    }
}

extension ArraySlice {
    var head: T? {
        return self.isEmpty ? nil : self[0]
    }

    var tail: ArraySlice<T> {
        if (self.isEmpty) {
            return self
        }
        return self[(self.startIndex+1)..<self.endIndex]
    }

    var decompose: (head: T, tail: ArraySlice<T>)? {
        return self.isEmpty ? nil
            : (self[self.startIndex], self.tail)
    }
}

extension Character: Printable {
    public var description: String {
        return "\"(self)\""
    }
}

public func eof<A>() -> Parser<A, ()> {
    return Parser { stream in
        if (stream.isEmpty) {
            return one(((), stream))
        }
        return none()
    }
}

public func testParser<A>(parser: Parser<Character, A>,
    input: String) -> String {

        var result: [String] = []
        for (x, s) in parser.p(input.slice) {
            result += ["Success, found \(x), remainder: \(Array(s))"]
        }
        return result.isEmpty ? "Parsing failed." : join("\n", result)
}

public struct Parser<Token, Result> {
    public let p: ArraySlice<Token> -> SequenceOf<(Result, ArraySlice<Token>)>
}

func parseA() -> Parser<Character, Character> {
    let a: Character = "a"

    return Parser { x in
        if let (head, tail) = x.decompose {
            if head == a {
                return one((a, tail))
            }
        }
        return none()
    }
}

testParser(parseA(), "abcd")

testParser(parseA(), "test")


func parseCharacter(character: Character) -> Parser<Character, Character> {
    return Parser { x in
        if let (head, tail) = x.decompose {
            if head == character {
                return one((character, tail))
            }
        }
        return none()
    }
}


testParser(parseCharacter("t"), "test")

testParser(parseCharacter("t"), "fast")

func satisfy<Token>(condition: Token -> Bool) -> Parser<Token, Token> {
    return Parser { x in
        if let (head, tail) = x.decompose {
            if condition(head) {
                return one((head, tail))
            }
        }
        return none()
    }
}

func token<Token: Equatable>(t: Token) -> Parser<Token, Token> {
    return satisfy { $0 == t }
}

//: ### Choice

infix operator <|> { associativity right precedence 130 }
func <|> <Token, A>(l: Parser<Token, A>, r: Parser<Token, A>) -> Parser<Token, A> {
    return Parser { input in
        l.p(input) + r.p(input)
    }
}

let a:Character = "a"
let b:Character = "b"

testParser(token(a) <|> token(b), "bcd")


//: ### Sequence

func sequence<Token, A, B>(l: Parser<Token, A>, r: Parser<Token, B>) -> Parser<Token, (A,B)> {
    return Parser { input in
        let leftResults = l.p(input)
        return flatMap(leftResults) { a, leftRest in
            let rightResults = r.p(leftRest)
            return map(rightResults, { b, rightRest in
                ((a, b), rightRest)
            })
        }
    }
}

let x: Character = "x"
let y: Character = "y"

let p: Parser<Character, (Character, Character)> =
                                            sequence(token(x), token(y))

testParser(p, "xyz")


let z: Character = "z"

let p2 = sequence(sequence(token(x), token(y)), token(z))

//: Returns a nested tuple...
testParser(p2, "xyz")


func integerParser<Token>() -> Parser<Token, Character -> Int> {
    return Parser { input in
        return one(({ x in String(x).toInt()! }, input))
    }
}

testParser(integerParser(), "3")


func combinator<Token, A, B>(l: Parser<Token, A -> B>, r: Parser<Token, A>) -> Parser<Token, B> {
    return Parser { input in
        let leftResults = l.p(input)
        return flatMap(leftResults) { f, leftRemainder in
            let rightResults = r.p(leftRemainder)
            return map(rightResults) { x, rightRemainder in
                (f(x), rightRemainder)
            }
        }
    }
}

let three: Character = "3"

testParser(combinator(integerParser(), token(three)), "3")


func pure<Token, A>(value: A) -> Parser<Token, A> {
    return Parser { one((value, $0)) }
}


func toInteger(c: Character) -> Int {
    return String(c).toInt()!
}

testParser(combinator(pure(toInteger), token(three)), "3")

infix operator <*> { associativity left precedence 150 }
func <*><Token, A, B>(l: Parser<Token, A -> B>, r: Parser<Token, A>) -> Parser<Token, B> {
    return Parser { input in
        let leftResults = l.p(input)
        return flatMap(leftResults) { f, leftRemainder in
            let rightResults = r.p(leftRemainder)
            return map(rightResults) { x, y in
                (f(x), y)
            }
        }
    }
}

//: Blah, blah combinators and currying to the extreme.

//: ### Convenience Combinators

func characterFromSet(set: NSCharacterSet) -> Parser<Character, Character> {
    return satisfy { return member(set, $0) }
}

let decimals = NSCharacterSet.decimalDigitCharacterSet()
let decimalDigit = characterFromSet(decimals)

testParser(decimalDigit, "012")

func lazy<Token, A>(f: () -> Parser<Token, A>) -> Parser<Token, A> {
    return Parser { x in f().p(x) }
}

func zeroOrMore<Token, A>(p: Parser<Token, A>) -> Parser<Token, [A]> {
    return (pure(prepend) <*> p <*> lazy { zeroOrMore(p) }) <|> pure([])
}

func oneOrMore<Token, A>(p: Parser<Token, A>) -> Parser<Token, [A]> {
    return pure(prepend) <*> p <*> zeroOrMore(p)
}

let number = pure { characters in string(characters).toInt()! } <*> oneOrMore(decimalDigit)

testParser(number, "205")

infix operator </> { precedence 170 }
func </> <Token, A, B>(l: A -> B, r: Parser<Token, A>) -> Parser<Token, B> {
    return pure(l) <*> r
}

let plus: Character = "+"
func add(x: Int)(_: Character)(y: Int) -> Int {
    return x + y
}
let parseAddition = add </> number <*> token(plus) <*> number

testParser(parseAddition, "41+1")

infix operator <* { associativity left precedence 150 }
func <* <Token, A, B>(p: Parser<Token, A>, q: Parser<Token, B>) -> Parser<Token, A> {
    return {x in {_ in x} } </> p <*> q
}

infix operator *> { associativity left precedence 150 }
func *> <Token, A, B>(p: Parser<Token, A>, q: Parser<Token, B>) -> Parser<Token, B> {
    return {_ in {y in y} } </> p <*> q
}


let multiply: Character = "*"
println("multiply: \(multiply)")
let parseMultiplication = curry(*) </> number <* token(multiply) <*> number
testParser(parseMultiplication, "8*8")

//: ### A Simple Calculator

typealias Calculator = Parser<Character, Int>

/*
func operator0(character: Character, evaluate: (Int, Int) -> Int, operand: Calculator) -> Calculator {
    return curry { evaluate($0, $1) } </> operand <* token(character) <*> operand
}

func pAtom0() -> Calculator { return number }
func pMultiply0() -> Calculator { return operator0("*", *, pAtom0()) }
func pAdd0 -> Calculator { return operator0("+", +, pMultiply0()) }
func pExpression0 -> Calculator { return pAdd0() }

//: Wont' work
testParser(pExpression0(), "1+3*3")
*/

func operator1(character: Character, evaluate: (Int, Int) -> Int, operand: Calculator) -> Calculator {
    let withOperator = curry { evaluate($0, $1) } </> operand <* token(character) <*> operand
    return withOperator <|> operand
}

func pAtom1() -> Calculator { return number }
func pMultiply1() -> Calculator { return operator1("*", *, pAtom1()) }
func pAdd1() -> Calculator { return operator1("+", +, pMultiply1()) }
func pExpression1() -> Calculator { return pAdd1() }

testParser(pExpression1(), "1+3*3")


typealias Op = (Character, (Int, Int) -> Int)
let operatorTable: [Op] = [("*", *), ("/", /), ("+", +), ("-", -)]

func pExpression2() -> Calculator {
    return operatorTable.reduce(number) {
        (next: Calculator, op: Op) in
        operator1(op.0, op.1, next)
    }
}
//testParser(pExpression2(), "1+3*3")


infix operator </ { precedence 170 }
func </ <Token, A, B>(l: A, r: Parser<Token, B>)-> Parser<Token, A> {
    return pure(l) <* r
}

func optionallyFollowed<A>(l: Parser<Character, A>, r: Parser<Character, A -> A>) -> Parser<Character, A> {
    let apply: A -> (A -> A) -> A = { x in { f in f(x) } }
    return apply </> l <*> (r <|> pure { $0 })
}

func op(character: Character, evaluate: (Int, Int) -> Int, operand: Calculator) -> Calculator {
    let withOperator = curry(flip(evaluate)) </ token(character) <*> operand
    return optionallyFollowed(operand, withOperator)
}

func pExpression() -> Calculator {
    return operatorTable.reduce(number) { next, inOp in
        op(inOp.0, inOp.1, next)
    }
}

testParser(pExpression() <* eof(), "10-3*2")





