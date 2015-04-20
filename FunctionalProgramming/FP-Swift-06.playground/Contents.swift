// QuickCheck

import Foundation

let numberOfIterations = 20

func random(#from: Int, #to: Int) -> Int {
    return from + (Int(arc4random()) % (to-from))
}

func tabulate<A>(times: Int, f: Int -> A) -> [A] {
    return Array(0..<times).map(f)
}

protocol Smaller {
    func smaller() -> Self?
}

protocol Arbitrary: Smaller {
    class func arbitrary() -> Self
}

extension Int: Arbitrary {
    static func arbitrary() -> Int {
        return Int(arc4random())
    }
}

//Int.arbitrary()

extension Character: Arbitrary {
    static func arbitrary() -> Character {
        return Character(UnicodeScalar(random(from: 65, to: 90)))
    }

    func smaller() -> Character? { return nil }
}

extension String: Arbitrary {
    static func arbitrary() -> String {
        let randomLength = random(from: 0, to: 40)
        let randomCharacters = tabulate(randomLength) {
            _ in
                Character.arbitrary()
        }
        return reduce(randomCharacters, "") { $0 + String($1) }
    }
}

String.arbitrary()

extension CGFloat: Arbitrary {
    func smaller() -> CGFloat? {
        return nil
    }

    static func arbitrary() -> CGFloat {
        let random: CGFloat = CGFloat(arc4random())
        let maxUint = CGFloat(UInt32.max)
        return 10000 * ((random - maxUint/2) / maxUint)
    }
}

extension CGSize: Arbitrary {
    func smaller() -> CGSize? {
        return nil
    }

    static func arbitrary() -> CGSize {
        return CGSizeMake(CGFloat.arbitrary(), CGFloat.arbitrary())
    }
}

func check1<A: Arbitrary>(message: String, prop: A -> Bool) -> () {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        if !prop(value) {
            println("\"\(message)\" doesn't hold: \(value)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}

func area(size: CGSize) -> CGFloat {
    return size.width * size.height
}

check1("Area should be at least 0") { size in area(size) >= 0.0 }

check1("Every string starts with hello") { (s: String) in
    s.hasPrefix("Hello")
}

// After adding a protocol for making smaller values

extension Int: Smaller {
    func smaller() -> Int? {
        return self == 0 ? nil : self/2
    }
}

100.smaller()

extension String: Smaller {
    func smaller() -> String? {
        return self.isEmpty ? nil : dropFirst(self)
    }
}

func iterateWhile<A>(condition: A -> Bool, initialValue: A, next: A -> A?) -> A {
    if let x = next(initialValue) {
        if condition(x) {
            return iterateWhile(condition, x, next)
        }
    }
    return initialValue
}

func check2<A: Arbitrary>(message: String, prop: A -> Bool) -> () {
    for _ in 0..<numberOfIterations {
        let value = A.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile({ !prop($0) }, value) {
                $0.smaller()
            }
            println("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}

// Functional version of QuickSort, pp101

func qsort (var array: [Int]) -> [Int] {
    if array.isEmpty { return [] }
    let pivot = array.removeAtIndex(0)
    let lesser = array.filter { $0 < pivot }
    let greater = array.filter { $0 >= pivot }
    return qsort(lesser) + [pivot] + qsort(greater)
}

extension Array: Smaller {
    func smaller() -> [T]? {
        if !self.isEmpty {
            return Array(dropFirst(self))
        }
        return nil
    }
}

func arbitraryArray<X: Arbitrary>() -> [X] {
    let randomLength = Int(arc4random() % 50)
    return tabulate(randomLength) { _ in
        return X.arbitrary()
    }
}

/*
// Can't work pp 103
extension Array<T: Arbitrary>: Arbitrary {
    static func arbitrary() -> [T] {

    }
}

check2("qsort should behave like sort") { (x: [Int]) in
    return qsort(x) == x.sorted(<)
}
*/

struct ArbitraryI<T> {
    let arbitrary: () -> T
    let smaller: T -> T?
}

func checkHelper<A>(arbitraryInstance:ArbitraryI<A>,
                    prop: A -> Bool, message: String) -> () {
    for _ in 0..<numberOfIterations {
        let value = arbitraryInstance.arbitrary()
        if !prop(value) {
            let smallerValue = iterateWhile({ !prop($0) }, value, arbitraryInstance.smaller)
            println("\"\(message)\" doesn't hold: \(smallerValue)")
            return
        }
    }
    println("\"\(message)\" passed \(numberOfIterations) tests.")
}

func check<X: Arbitrary>(message: String, prop: X -> Bool) -> () {
    let instance = ArbitraryI(arbitrary: { X.arbitrary() },
                                smaller: { $0.smaller() })
    checkHelper(instance, prop, message)
}

func check<X: Arbitrary>(message: String, prop: [X] -> Bool) -> () {
    let instance = ArbitraryI(arbitrary: arbitraryArray,
                              smaller: { (x: [X]) in x.smaller() })
    checkHelper(instance, prop, message)
}


check("qsort should behave like sort") { (x: [Int]) in
    return qsort(x) == x.sorted(<)
}
