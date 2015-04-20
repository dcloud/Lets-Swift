//: # Diagrams

import Cocoa

//: See SupportCode.swift for support code


class Box<T> {
    let unbox: T
    init(_ value: T) { self.unbox = value }
}

enum Primitive {
    case Ellipse
    case Rectangle
    case Text(String)
}

enum Attribute {
    case FillColor(NSColor)
}

enum Diagram {
    case Prim(CGSize, Primitive)
    case Beside(Box<Diagram>, Box<Diagram>)
    case Below(Box<Diagram>, Box<Diagram>)
    case Attributed(Attribute, Box<Diagram>)
    case Align(Vector2D, Box<Diagram>)
}

extension Diagram {
    var size: CGSize {
        switch self {
        case .Prim(let size, _):
            return size
        case .Attributed(_, let x):
            return x.unbox.size
        case .Beside(let l, let r):
            let sizeL = l.unbox.size
            let sizeR = r.unbox.size
            return CGSizeMake(sizeL.width + sizeR.width,
                                max(sizeL.height, sizeR.height))
        case .Below(let l, let r):
            let sizeL = l.unbox.size
            let sizeR = r.unbox.size
            return CGSizeMake(max(sizeL.width, sizeR.width),
                                sizeL.height + sizeR.height)
        case .Align(_, let r):
            return r.unbox.size
        }
    }
}

func fit(alignment: Vector2D, inputSize: CGSize, rect: CGRect) -> CGRect {
    let scaleSize = rect.size / inputSize
    let scale = min(scaleSize.width, scaleSize.height)
    let size = scale * inputSize
    let space = alignment.size * (size - rect.size)
    return CGRect(origin: rect.origin - space.point, size: size)
}


fit(Vector2D(x: 0.5, y: 0.5), CGSizeMake(1, 1), CGRectMake(0, 0, 200, 100))
fit(Vector2D(x: 0, y: 0.5), CGSizeMake(1, 1), CGRectMake(0, 0, 200, 100))


func draw(context: CGContextRef, bounds: CGRect, diagram: Diagram) {
    switch diagram {
    case .Prim(let size, .Ellipse):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), size, bounds)
        CGContextFillEllipseInRect(context, frame)
    case .Prim(let size, .Rectangle):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), size, bounds)
        CGContextFillRect(context, frame)
    case .Prim(let size, .Text(let text)):
        let frame = fit(Vector2D(x: 0.5, y: 0.5), size, bounds)
        let font = NSFont.systemFontOfSize(12)
        let attributes = [NSFontAttributeName: font]
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        attributedText.drawInRect(frame)
    case .Attributed(.FillColor(let color), let d):
        CGContextSaveGState(context)
        color.set()
        draw(context, bounds, d.unbox)
        CGContextRestoreGState(context)
    case .Beside(let left, let right):
        let l = left.unbox
        let r = right.unbox
        let (lFrame, rFrame) = splitHorizontal(bounds, l.size/diagram.size)
        draw(context, lFrame, l)
        draw(context, rFrame, r)
    case .Below(let top, let bottom):
        let t = top.unbox
        let b = bottom.unbox
        let (lFrame, rFrame) = splitVertical(bounds, b.size/diagram.size)
        draw(context, lFrame, b)
        draw(context, rFrame, t)
    case .Align(let vec, let d):
        let diagram = d.unbox
        let frame = fit(vec, diagram.size, bounds)
        draw(context, frame, diagram)
    }
}

class Draw: NSView {
    let diagram: Diagram

    init(frame frameRect: NSRect, diagram: Diagram) {
        self.diagram = diagram
        super.init(frame: frameRect)
    }

    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported")
    }

    override func drawRect(dirtyRect: NSRect) {
        if let context = NSGraphicsContext.currentContext() {
            draw(context.cgContext, self.bounds, diagram)
        }
    }
}

func pdf(diagram: Diagram, width: CGFloat) -> NSData {
    let unitSize = diagram.size
    let height = width * (unitSize.height/unitSize.width)
    let v: Draw = Draw(frame: NSMakeRect(0, 0, width, height), diagram: diagram)
    return v.dataWithPDFInsideRect(v.bounds)
}

//: ## Combinators

func rect(#width: CGFloat, #height: CGFloat) -> Diagram {
    return Diagram.Prim(CGSizeMake(width, height), .Rectangle)
}

func circle(#diameter: CGFloat) -> Diagram {
    return Diagram.Prim(CGSizeMake(diameter, diameter), .Ellipse)
}

func text(#width: CGFloat, #height: CGFloat, text theText: String) -> Diagram {
    return Diagram.Prim(CGSizeMake(width, height), .Text(theText))
}

func square(#side: CGFloat) -> Diagram {
    return rect(width: side, height: side)
}

infix operator ||| { associativity left }
func ||| (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Beside(Box(l), Box(r))
}

infix operator --- { associativity left }
func --- (l: Diagram, r: Diagram) -> Diagram {
    return Diagram.Below(Box(l), Box(r))
}

extension Diagram {
    func fill(color: NSColor) -> Diagram {
        return Diagram.Attributed(Attribute.FillColor(color), Box(self))
    }

    func alignTop() -> Diagram {
        return Diagram.Align(Vector2D(x: 0.5, y: 1), Box(self))
    }

    func alignBottom() -> Diagram {
        return Diagram.Align(Vector2D(x: 0.5, y: 1), Box(self))
    }
}

let empty: Diagram = rect(width: 0, height: 0)

func hcat(diagrams: [Diagram]) -> Diagram {
    return diagrams.reduce(empty, combine: |||)
}

// XCPShowView

