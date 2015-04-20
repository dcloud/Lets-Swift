// Playground - noun: a place where people can play

import Foundation

func computeIntArray(xs: [Int], f: Int -> Int) -> [Int] {
    var result: [Int] = []
    for x in xs {
        result.append(f(x))
    }
    return result
}

func doubleIntArray(xs: [Int]) -> [Int] {
    return computeIntArray(xs) { x in x * 2 }
}

// If we were to define map ourselves

func map<T, U>(xs: [T], f: T -> U) -> [U] {
    var result: [U] = []
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
    return map(xs) { x in x * 2 }
}

func isEvenArray(xs: [Int]) -> [Bool] {
    return map(xs) { x in x % 2 == 0 }
}

let values = [1, 2, 3, 4]

doubleArray(values)

isEvenArray(values)

func doubleArrayRedux(xs: [Int]) -> [Int] {
    return xs.map { x in 2 * x }
}

doubleArrayRedux(values)


// filter

let exampleFiles = ["README.md", "HelloWorld.swift", "HelloSwift.swift", "FlappyBird.swift"]

func getSwiftFiles(files: [String]) -> [String] {
    var results: [String] = []
    for f in files {
        if f.hasSuffix("swift") {
            results.append(f)
        }
    }
    return results
}

getSwiftFiles(exampleFiles)

exampleFiles.filter { file in file.hasSuffix("swift") }

// Sum

func sum(xs: [Int]) -> Int {
    var result: Int = 0
    for x in xs {
        result += x
    }
    return result
}

let xs = [1, 2, 3, 4]
sum(xs)

// reduce

func reduce<A, R>(arr: [A], initialValue: R, combine: (R, A) -> R) -> R {
    var result = initialValue
    for i in arr {
        result = combine(result, i)
    }
    return result
}

func sumUsingReduce(xs: [Int]) -> Int {
    return reduce(xs, 0) { result, x in result + x }
}

func productUsingResult(xs: [Int]) -> Int {
    return reduce(xs, 1, *)
}

func concatUsingRecude(xs: [String]) -> String {
    return reduce(xs, "", +)
}

concatUsingRecude(["This", "is", "silly"])

// Using real reduce

let matrix = [[1, 2, 3, 4], [9, 8, 7, 6], [1, 3, 5, 7, 9]]

func flatten<T>(xss: [[T]]) -> [T] {
    var result: [T] = []
    for xs in xss {
        result += xs
    }
    return result
}

func flattenUsingReduce<T>(xss: [[T]]) -> [T] {
    return reduce(xss, []) { result, xs in result + xs }
}

flattenUsingReduce(matrix)


// Putting it all together

struct City {
    let name: String
    let population: Int
}

let paris = City(name: "Paris", population: 2243)
let madrid = City(name: "Madrid", population: 3216)
let amsterdam = City(name: "Amsterdam", population: 811)
let berlin = City(name: "Berlin", population: 3397)

let cities = [paris, madrid, amsterdam, berlin]

func scale(city: City) -> City {
    return City(name: city.name, population: city.population * 1000)
}

let cityText = cities.filter({city in city.population > 1000 })
      .map(scale)
      .reduce("City: Population") { result, c in
        return result + "\n" + "\(c.name): \(c.population)"
}

println(cityText)


