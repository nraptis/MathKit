//
//  DirectedWeightPoint.swift
//  MathKit
//
//  Created by Nicholas Raptis on 5/10/25.
//

import Foundation

public class DirectedWeightPoint: PointProtocol {
    
    public init() {
        
    }
    
    public typealias Point = Math.Point
    public var x = Float(0.0)
    public var y = Float(0.0)
    public var tanDirectionIn = Float(0.0)
    public var tanDirectionOut = Float(0.0)
    public var tanMagnitudeIn = Float(10.0)
    public var tanMagnitudeOut = Float(10.0)
    public var isManualTanHandleEnabled = false
    public var isUnifiedTan = true
    public var point: Point {
        Point(x: x, y: y)
    }
}
