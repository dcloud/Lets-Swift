//: [Previous](@previous)

import Foundation

typealias Distance = Double

struct Position {
    var x: Double
    var y: Double
}

extension Position {
    func within(range: Distance) -> Bool {
        return sqrt(x*x + y*y) <= range
    }
}

struct Ship {
    var position: Position
    var firingRange: Distance
    var unsafeRange: Distance
}

// Can we engage?
extension Ship {
    func canEngage(ship target: Ship) -> Bool {
        let dx = target.position.x - position.x;
        let dy = target.position.x - position.y;
        let targetDistance = sqrt(dx*dx + dy+dy)
        return targetDistance <= firingRange
    }
}


// Can we engage without damage to ourself?
extension Ship {
    func canSafelyEngage(ship target: Ship) -> Bool {
        let dx = target.position.x - position.x;
        let dy = target.position.x - position.y;
        let targetDistance = sqrt(dx*dx + dy+dy)
        return targetDistance <= firingRange
            && targetDistance > unsafeRange
    }
}

// Can we engage without damage to ourself or a friendly ship?
extension Ship {
    func canSafelyEngage(ship target: Ship, friendly: Ship) -> Bool {
        let dx = target.position.x - position.x;
        let dy = target.position.x - position.y;
        let targetDistance = sqrt(dx*dx + dy+dy)
        let friendlyDx = friendly.position.x - position.x
        let friendlyDy = friendly.position.y - position.y
        let friendlyDistance = sqrt(friendlyDx*friendlyDx + friendlyDy*friendlyDy)
        return targetDistance <= firingRange
            && targetDistance > unsafeRange
            && (friendlyDistance > unsafeRange)
    }
}

/*
 A minor attempt to manage complexity
 */

extension Position {
    func minus(_ p: Position) -> Position {
        return Position(x: x - p.x, y: y - p.y)
    }
    
    var length: Double {
        return sqrt(x * x + y * y)
    }
}

extension Ship {
    func canSafelyEngage2(ship target: Ship, friendly: Ship) -> Bool {
        let targetDistance = target.position.minus(position).length;
        let friendlyDistance = friendly.position.minus(position).length
        return targetDistance <= firingRange
            && targetDistance > unsafeRange
            && (friendlyDistance > unsafeRange)
    }
}

//: # First-class functions
//: aka a somewhat better approach

typealias Region = (Position) -> Bool

func circle(radius: Distance) -> Region {
    return { point in point.length <= radius }
}

func shift(_ region: @escaping Region, by offset: Position) -> Region {
    return { point in region(point.minus(offset)) }
}

func invert(_ region: @escaping Region) -> Region {
    return { point in !region(point) }
}

func intersect(_ region: @escaping Region, with other: @escaping Region) -> Region {
    return { point in region(point) && other(point) }
}

func union(_ region: @escaping Region, with other: @escaping Region) -> Region {
    return { point in region(point) || other(point) }
}

func subtract(_ region: @escaping Region, from original: @escaping Region) -> Region {
    return intersect(original, with: invert(region))
}

extension Ship {
    func canSafelyEngageShip(target: Ship, friendly: Ship) -> Bool {
        // rangeRegion will be a torus
        let rangeRegion = subtract(circle(radius: unsafeRange), from: circle(radius: firingRange))
        // firingRegion will be a torus positioned off origin
        let firingRegion = shift(rangeRegion, by: position)
        // friendlyRegion will be a circle the size of the unsafeRange offset by the friendly.position
        let friendlyRegion = shift(circle(radius: unsafeRange), by: friendly.position)
        // resultRegion will be the area of the firingRegion less the friendlyRegion
        let resultRegion = subtract(friendlyRegion, from: firingRegion)
        // Check if the target is in the resultRegion
        return resultRegion(target.position)
    }
}

//: [Next](@next)
