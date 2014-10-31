// Playground - noun: a place where people can play

import Foundation

func computeIntArray(xs: [Int], f: Int -> Int) -> [Int] {
    var result: [Int] = []
    for x in xs {
        result.append(f(x))
    }
    return result
}

func genericComputeArray<T, U>(xs: [T], f: T -> U) -> [U] {
    var result: [U] = []
    for x in xs {
        result.append(f(x))
    }
    return result
}

func doubleArray(xs: [Int]) -> [Int] {
    return computeIntArray(xs) { x in x * 2 }
}

func isEvenArray(xs: [Int]) -> [Bool] {
    return genericComputeArray(xs) { x in x % 2 == 0 }
}


isEvenArray([1, 2, 3, 4])
