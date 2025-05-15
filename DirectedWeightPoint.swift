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
    
    public var tanMagnitudeIn = ControlPoint.defaultTanLength
    public var tanMagnitudeOut = ControlPoint.defaultTanLength
    
    public var isManualTanHandleEnabledIn = false
    public var isManualTanHandleEnabledOut = false
    
    public var point: Point {
        Point(x: x, y: y)
    }
}
