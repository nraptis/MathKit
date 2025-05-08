//
//  LineSegment.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 11/18/23.
//

import Foundation
import MathKit

public protocol LineSegment: AnyObject {
    typealias Point = MathKit.Math.Point
    typealias Vector = MathKit.Math.Vector
    var x1: Float { set get }
    var y1: Float { set get }
    var x2: Float { set get }
    var y2: Float { set get }
}

public extension LineSegment {
    var p1: Point {
        get {
            Point(x: x1, y: y1)
        }
        set {
            x1 = newValue.x
            y1 = newValue.y
        }
    }
    
    var p2: Point {
        get {
            Point(x: x2, y: y2)
        }
        set {
            x2 = newValue.x
            y2 = newValue.y
        }
    }
    
    func intersects(lineSegment: LineSegment) -> Bool {
        MathKit.Math.lineSegmentIntersectsLineSegment(line1Point1X: x1,
                                              line1Point1Y: y1,
                                              line1Point2X: x2,
                                              line1Point2Y: y2,
                                              line2Point1X: lineSegment.x1,
                                              line2Point1Y: lineSegment.y1,
                                              line2Point2X: lineSegment.x2,
                                              line2Point2Y: lineSegment.y2)
    }
    
}

public class AnyLineSegment: LineSegment {
    public var x1: Float
    public var y1: Float
    public var x2: Float
    public var y2: Float
    
    public var isTagged: Bool
    
    public init(x1: Float, y1: Float, x2: Float, y2: Float) {
        self.x1 = x1
        self.y1 = y1
        self.x2 = x2
        self.y2 = y2
        isTagged = false
    }
    
    public init(p1: Point, p2: Point) {
        x1 = p1.x
        y1 = p1.y
        x2 = p2.x
        y2 = p2.y
        isTagged = false
    }
}
