//: # Generators and Sequences

import UIKit

class CountDownGenerator: GeneratorType {
    typealias Element = Int

    var element: Element

    init<T>(array: [T]) {
        self.element = array.count - 1
    }

    func next() -> Element? {
        return self.element < 0 ? nil : element--
    }
}

let xs = ["A", "B", "C"]

let generator = CountDownGenerator(array: xs)

while let i = generator.next() {
    println("Element \(i) of the array is \(xs[i])")
}

class PowerGenerator: GeneratorType {
    typealias Element = NSDecimalNumber

    var power: NSDecimalNumber = NSDecimalNumber(int: 1)
    let two = NSDecimalNumber(int: 2)

    func next() -> Element? {
        power = power.decimalNumberByMultiplyingBy(two)
        return power
    }
}

func findPower(predicate: NSDecimalNumber -> Bool) -> NSDecimalNumber {
    let g = PowerGenerator()

    while let x = g.next() {
        if predicate(x) {
            return x
        }
    }
    return 0
}

findPower { $0.integerValue > 1000 }


class FileLinesGenerator: GeneratorType {
    typealias Element = String

    var lines: [String]

    init(filename: String) {
        if let contents = String(contentsOfFile: filename,
            encoding: NSUTF8StringEncoding, error: nil) {
                let newLine = NSCharacterSet.newlineCharacterSet()
                lines = contents.componentsSeparatedByCharactersInSet(newLine)
        } else {
            lines = []
        }
    }

    func next() -> Element? {
        if let nextLine = lines.first {
            lines.removeAtIndex(0)
            return nextLine
        } else {
            return nil
        }
    }
}


class LimitGenerator<G: GeneratorType>: GeneratorType {
    typealias Element = G.Element
    var limit = 0
    var generator: G

    init(limit: Int, generator: G) {
        self.limit = limit
        self.generator = generator
    }

    func next() -> Element? {
        if limit >= 0 {
            limit--
            return generator.next()
        } else {
            return nil
        }
    }
}


let limitedPowerGenerator = LimitGenerator(limit: 300, generator: PowerGenerator())

while let n = limitedPowerGenerator.next() {
    println("limitedPowerGenerator n = \(n)")
}

//: ## GeneratorOf

func countdown(start: Int) -> GeneratorOf<Int> {
    var i = start
    return GeneratorOf { return i < 0 ? nil : i-- }
}


func +<A>(var first: GeneratorOf<A>, var second: GeneratorOf<A>) -> GeneratorOf<A> {
    return GeneratorOf {
        if let x = first.next() {
            return x
        } else if let x = second.next() {
            return x
        }
        return nil
    }
}


//: ## Sequences


struct ReverseSequence<T>: SequenceType {
    var array: [T]

    init(array: [T]) {
        self.array = array
    }

    typealias Generator = CountDownGenerator
    func generate() -> Generator {
        return CountDownGenerator(array: array)
    }
}


let reverseSequence = ReverseSequence(array: xs)
let reverseGenerator = reverseSequence.generate()

while let i = reverseGenerator.next() {
    println("Index \(i) is \(xs[i])")
}

for i in ReverseSequence(array: xs) {
    println("Index \(i) is \(xs[i])")
}

let reverseElements = map(ReverseSequence(array: xs)) { i in xs[i] }

for x in reverseElements {
    println("Element is \(x)")
}

let lazyReverseElements = lazy(ReverseSequence(array: xs)).map { i in xs[i] }

for x in lazyReverseElements {
    println("Element is \(x)")
}

//: ### Case Study: Traversing a Binary Tree

let three: [Int] = Array(GeneratorOfOne(3))
let empty: [Int] = Array(GeneratorOfOne(nil))

func one<X>(x: X?) -> GeneratorOf<X> {
    return GeneratorOf(GeneratorOfOne(x))
}

//func inOrder<T>(tree: Tree<T>) -> GeneratorOf<T> {
//    switch tree:
//    case Tree.Leaf:
//        return GeneratorOf { return nil }
//    case let Tree.Node(left, x, right):
//        return inOrder(left.unbox) + one(X) + inOrder(right.unbox)
//}

//: ### Case Study: Better Shrinking in QuickCheck
//: Improvements to the `Smaller` protocol

protocol Smaller {
    func smaller() -> GeneratorOf<Self>
}

//: From CH 09: Purely Functional data structures
extension Array {
    var decompose : (head: T, tail: [T])? {
        return (count > 0) ? (self[0], Array(self[1..<count])) : nil
    }
}

func removeElement<T>(var array: [T]) -> GeneratorOf<[T]> {
    var i = 0
    return GeneratorOf {
        if i < array.count {
            var result = array
            result.removeAtIndex(i)
            i++
            return result
        }
        return nil
    }
}

Array(removeElement([1, 2, 3]))

func map<A, B>(var g: GeneratorOf<A>, f: A -> B) -> GeneratorOf<B> {
    return GeneratorOf {
        g.next().map(f)
    }
}

func smaller1<T>(array: [T]) -> GeneratorOf<[T]> {
    if let (head, tail) = array.decompose {
        let gen1: GeneratorOf<[T]> = one(tail)
        let gen2: GeneratorOf<[T]> = map(smaller1(tail)) {
            smallerTail in
            [head] + smallerTail
        }
        return gen1 + gen2
    } else {
        return one(nil)
    }
}

Array(smaller1([1, 2, 3]))

extension Int: Smaller {
    func smaller() -> GeneratorOf<Int> {
        let result: Int? = self < 0 ? nil : self.predecessor()
        return one(result)
    }
}

func smaller<T: Smaller>(ls: [T]) -> GeneratorOf<[T]> {
    if let (head, tail) = ls.decompose {
        let gen1: GeneratorOf<[T]> = one(tail)
        let gen2: GeneratorOf<[T]> = map(smaller(tail)) {
            xs in
            [head] + xs
        }
        let gen3: GeneratorOf<[T]> = map(head.smaller(), { x in
            [x] + tail
        })
        return gen1 + gen2 + gen3
    } else {
        return one(nil)
    }
}

Array(smaller([1, 2, 3]))


/*: 

### Beyond Map and Filter

Some of the implementations in this section exist in Swift 1.2
*/

let s1 = SequenceOf([1, 2])
for s in s1 {
    println("s is \(s)")
}

func +<A>(l: SequenceOf<A>, r: SequenceOf<A>) -> SequenceOf<A> {
    return SequenceOf( l.generate() + r.generate() )
}


let s = SequenceOf([1, 2, 3]) + SequenceOf([4, 5, 6])

struct JoinedGenerator<A>: GeneratorType {
    typealias Element = A

    var generator: GeneratorOf<GeneratorOf<A>>
    var current: GeneratorOf<A>?

    init(_ g: GeneratorOf<GeneratorOf<A>>) {
        generator = g
        current = generator.next()
    }

    mutating func next() -> A? {
        if var c = current {
            if let x = c.next() {
                return x
            } else {
                current = generator.next()
                return next()
            }
        }
        return nil
    }
}

func join<A>(s: SequenceOf<SequenceOf<A>>) -> SequenceOf<A> {
    return SequenceOf {
        JoinedGenerator(map(s.generate()) { g in
            g.generate()
        })
    }
}

func flatMap<A, B>(xs: SequenceOf<A>, f: A -> SequenceOf<B>) -> SequenceOf<B> {
    return join(SequenceOf(map(xs, f)))
}

