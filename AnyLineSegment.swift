//
//  AnyLineSegment.swift
//  MathKit
//
//  Created by Nicholas Raptis on 5/10/25.
//

import Foundation

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
