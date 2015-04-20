// Playground - noun: a place where people can play

import UIKit
import Foundation

typealias Position = CGPoint
typealias Distance = CGFloat

// Showing a task getting more complicated

func inRange1(target: Position, range: Distance) -> Bool {
    return sqrt(target.x * target.x + target.y * target.y) <= range
}

func inRange2(target: Position, ownPosition: Position,
    range: Distance) -> Bool {
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y

    let targetDistance = sqrt(dx*dx + dy*dy)
    return targetDistance <= range
}

let minimumDistance: Distance = 2.0

func inRange3(target: Position, ownPosition: Position, range: Distance) -> Bool {
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y

    let targetDistance = sqrt(dx*dx + dy*dy)
    return targetDistance <= range && targetDistance >= minimumDistance

}

func inRange4(target: Position, ownPosition: Position, friendly: Position, range: Distance) -> Bool {
    let dx = ownPosition.x - target.x
    let dy = ownPosition.y - target.y
    let targetDistance = sqrt(dx*dx + dy*dy)

    let friendlyDx = friendly.x - target.x
    let friendlyDy = friendly.y - target.y
    let friendlyDistance = sqrt(friendlyDx * friendlyDx + friendlyDy * friendlyDy)

    return targetDistance <= range
    && targetDistance >= minimumDistance
    && friendlyDistance >= targetDistance
}

// ---------------------------------

typealias Region = Position -> Bool

func circle(radius: Distance) -> Region {
    return { p in sqrt(p.x * p.x + p.y * p.y) <= radius }
}

func shift(offset: Position, region: Region) -> Region {
    return { point in
        let shiftedPoint = Position(x: point.x + offset.x,
                                    y: point.y + offset.y)
        return region(shiftedPoint)
    }
}

func invert(region: Region) -> Region {
    return { point in !region(point) }
}

func intersection(region1: Region, region2: Region) -> Region {
    return { point in region1(point) && region2(point) }
}

func union(region1: Region, region2: Region) -> Region {
    return { point in region1(point) || region2(point) }
}

func difference(region: Region, minusRegion: Region) -> Region {
    return intersection(region, invert(minusRegion))
}


func inRange(ownPosition: Position, target: Position, friendly: Position, range: Distance) -> Bool {
    let rangeRegion = difference(circle(range), circle(minimumDistance))
    let targetRegion = shift(ownPosition, rangeRegion)
    let friendlyRegion = shift(friendly, circle(minimumDistance))
    let resultRegion = difference(targetRegion, friendlyRegion)
    return resultRegion(target)
}
