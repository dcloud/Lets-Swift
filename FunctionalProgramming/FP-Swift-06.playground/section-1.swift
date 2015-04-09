//: # The Value of Immutability

import UIKit

struct PointStruct {
    var x: Int
    var y: Int
}

/*
    Because struct is a value type, assignment is a copy operation resulting in two unique instances
*/
var structPoint = PointStruct(x: 1, y: 2)
var sameStructPoint = structPoint
sameStructPoint.x = 3

println("\(sameStructPoint.x) == \(structPoint.x)? \(sameStructPoint.x == structPoint.x)")


/* 
    Classes are a reference type, so assignment will create multiple references to the same instance.
*/

class PointClass {
    var x: Int
    var y: Int

    init(x: Int, y: Int) {
        self.x = x
        self.y = y
    }
}

var classPoint = PointClass(x: 1, y: 2)
var sameClassPoint = classPoint
sameClassPoint.x = 3

println("\(sameClassPoint.x) == \(classPoint.x)? \(sameClassPoint.x == classPoint.x)")


/*
    Value types, such as structs are copied when passed to functions
*/

func setStructToOrigin(var point: PointStruct) -> PointStruct {
    point.x = 0
    point.y = 0

    return point
}

var structOrigin: PointStruct = setStructToOrigin(structPoint)

println("\(structOrigin.x) == \(structPoint.x)? \(structOrigin.x == structPoint.x)")


/*
    Reference types, such as classes are not copied, but manipulated directly
*/

func setClassToOrigin(var point: PointClass) -> PointClass {
    point.x = 0
    point.y = 0
    return point
}
var classOrigin = setClassToOrigin(classPoint)

println("\(classOrigin.x) == \(classPoint.x)? \(classOrigin.x == classPoint.x)")

