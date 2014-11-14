// FP-Swift 03 - Optionals

import Foundation


let cities = ["Paris": 2243, "Madrid": 3216, "Amsterdam": 881, "Berlin": 3397]

cities["foo"] ?? 0

(cities["Paris"] ?? 0) * 1000

func incrementOptional(optional: Int?) -> Int? {
    return optional.map { x in x + 1 }
}

let x: Int? = 3
let y: Int? = nil
//let z: Int? = x + y

func addOptionals(optionalX: Int?, optionalY: Int?) -> Int? {
    if let x  = optionalX {
        if let y = optionalY {
            return x + y
        }
    }
    return nil
}

let capitals = ["France": "Paris", "Spain": "Madrid", "The Netherlands": "Amsterdam", "Belgium": "Brussels"]

func populationOfCapital(country: String) -> Int? {
    if let capital = capitals[country] {
        if let population = cities[capital] {
            return population * 1000
        }
    }
    return nil
}

populationOfCapital("France")

infix operator >>= {}

func >>=<U, T>(optional: T?, f: T -> U?) -> U? {
    if let x = optional {
        return f(x)
    } else {
        return nil
    }
}

func addOptionals2(optionalX: Int?, optionalY: Int?) -> Int? {
    return optionalX >>= { x in
        optionalY >>= { y in
            x + y
        }
    }
}

func populationOfCapital2(country: String) -> Int? {
    return capitals[country] >>= { capital in
        cities[capital] >>= { population in
            return population * 1000
        }
    }
}

populationOfCapital2("France")

