//
// This file (and all other Swift source files in the Sources directory of this playground) will be precompiled into a framework which is automatically made available to FP-Swift-10.playground.
//

import Cocoa

public extension NSGraphicsContext {
    var cgContext : CGContextRef {
        let opaqueContext = COpaquePointer(self.graphicsPort)
        return Unmanaged<CGContextRef>.fromOpaque(opaqueContext)
            .takeUnretainedValue()
    }
}

public func *(l: CGPoint, r: CGRect) -> CGPoint {
    return CGPointMake(r.origin.x + l.x*r.size.width,
        r.origin.y + l.y*r.size.height)
}

public func *(l: CGFloat, r: CGPoint) -> CGPoint {
    return CGPointMake(l*r.x, l*r.y)
}
public func *(l: CGFloat, r: CGSize) -> CGSize {
    return CGSizeMake(l*r.width, l*r.height)
}

func pointWise(f: (CGFloat, CGFloat) -> CGFloat,
    l: CGSize, r: CGSize) -> CGSize {

        return CGSizeMake(f(l.width, r.width), f(l.height, r.height))
}

func pointWise(f: (CGFloat, CGFloat) -> CGFloat,
    l: CGPoint, r:CGPoint) -> CGPoint {

        return CGPointMake(f(l.x, r.x), f(l.y, r.y))
}

public func /(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(/, l, r)
}
public func *(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(*, l, r)
}
public func +(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(+, l, r)
}
public func -(l: CGSize, r: CGSize) -> CGSize {
    return pointWise(-, l, r)
}

public func -(l: CGPoint, r: CGPoint) -> CGPoint {
    return pointWise(-, l, r)
}

public func +(l: CGPoint, r: CGPoint) -> CGPoint {
    return pointWise(+, l, r)
}

public func *(l: CGPoint, r: CGPoint) -> CGPoint {
    return pointWise(*, l, r)
}

public extension CGSize {
    var point : CGPoint {
        return CGPointMake(self.width, self.height)
    }
}

func isHorizontalEdge(edge: CGRectEdge) -> Bool {
    switch edge {
    case .MaxXEdge, .MinXEdge:
        return true
    default:
        return false
    }
}

public func splitRect(rect: CGRect, sizeRatio: CGSize,
    edge: CGRectEdge) -> (CGRect, CGRect) {

        let ratio = isHorizontalEdge(edge) ? sizeRatio.width
            : sizeRatio.height
        let multiplier = isHorizontalEdge(edge) ? rect.width
            : rect.height
        let distance : CGFloat = multiplier * ratio
        var mySlice : CGRect = CGRectZero
        var myRemainder : CGRect = CGRectZero
        CGRectDivide(rect, &mySlice, &myRemainder, distance, edge)
        return (mySlice, myRemainder)
}

public func splitHorizontal(rect: CGRect,
    ratio: CGSize) -> (CGRect, CGRect) {

        return splitRect(rect, ratio, CGRectEdge.MinXEdge)
}

public func splitVertical(rect: CGRect,
    ratio: CGSize) -> (CGRect, CGRect) {

        return splitRect(rect, ratio, CGRectEdge.MinYEdge)
}

extension CGRect {
    public init(center: CGPoint, size: CGSize) {
        let origin = CGPointMake(center.x - size.width/2,
            center.y - size.height/2)
        self.init(origin: origin, size: size)
    }
}

// A 2-D Vector
public struct Vector2D {
    public let x: CGFloat
    public let y: CGFloat

    public init(x: CGFloat, y: CGFloat) {
        self.x = x
        self.y = y
    }

    public var point : CGPoint { return CGPointMake(x, y) }

    public var size : CGSize { return CGSizeMake(x, y) }
}

public func *(m: CGFloat, v: Vector2D) -> Vector2D {
    return Vector2D(x: m * v.x, y: m * v.y)
}

extension Dictionary {
    var keysAndValues: [(Key, Value)] {
        var result: [(Key, Value)] = []
        for item in self {
            result.append(item)
        }
        return result
    }
}

public func normalize(input: [CGFloat]) -> [CGFloat] {
    let maxVal = input.reduce(0) { max($0, $1) }
    return input.map { $0 / maxVal }
}