//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to FP-Swift-12.playground.
//

//: From "Additional Code" section of book

import Foundation

public func curry<A, B, C>(f: (A, B) -> C) -> A -> B -> C {
    return { x in { y in f(x, y) } }
}
public func curry<A, B, C, D>(f: (A, B, C) -> D) -> A -> B -> C -> D {
    return { a in { b in { c in f(a, b, c) } } }
}

public func none<A>() -> SequenceOf<A> {
    return SequenceOf(GeneratorOf { nil } )
}
public func one<A>(x: A) -> SequenceOf<A> {
    return SequenceOf(GeneratorOfOne(x))
}

public struct JoinedGenerator<A>: GeneratorType {
    typealias Element = A

    var generator: GeneratorOf<GeneratorOf<A>>
    var current: GeneratorOf<A>?

    init(_ g: GeneratorOf<GeneratorOf<A>>) {
        generator = g
        current = generator.next()
    }

    mutating public func next() -> A? {
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

public func flatMap<A, B>(ls: SequenceOf<A>,
    f: A -> SequenceOf<B>) -> SequenceOf<B> {

        return join(map(ls, f))
}

public func map<A, B>(var g: GeneratorOf<A>, f: A -> B) -> GeneratorOf<B> {
    return GeneratorOf { map(g.next(), f) }
}

public func map<A, B>(var s: SequenceOf<A>, f: A -> B) -> SequenceOf<B> {
    return SequenceOf {  map(s.generate(), f) }
}

public func join<A>(s: SequenceOf<SequenceOf<A>>) -> SequenceOf<A> {
    return SequenceOf {
        JoinedGenerator(map(s.generate()) {
            $0.generate()
            })
    }
}

public func +<A>(l: SequenceOf<A>, r: SequenceOf<A>) -> SequenceOf<A> {
    return join(SequenceOf([l, r]))
}

public func const<A, B>(x: A) -> B -> A {
    return { _ in x }
}

public func prepend<A>(l: A) -> [A] -> [A] {
    return { (x: [A]) in [l] + x }
}

public func string(characters: [Character]) -> String {
    var s = ""
    s.extend(characters)
    return s
}

public func member(set: NSCharacterSet, character: Character) -> Bool {
    let unichar = (String(character) as NSString).characterAtIndex(0)
    return set.characterIsMember(unichar)
}

public func flip<A, B, C>(f: (B, A) -> C) -> (A, B) -> C {
    return { (x, y) in f(y, x) }
}

