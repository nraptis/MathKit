//
//  ControlPoint.swift
//  MathKit
//
//  Created by Nicholas Raptis on 5/13/25.
//

import Foundation

open class ControlPoint {
    
    public static let defaultTanLength = Float(80.0)
    
    public init() {
        
    }
    
    public var x = Float(0.0)
    public var y = Float(0.0)
    
    public var tanDirectionIn = Float(0.0)
    public var tanDirectionOut = Float(0.0)
    public var tanMagnitudeIn = ControlPoint.defaultTanLength
    public var tanMagnitudeOut = ControlPoint.defaultTanLength
    
    public var isManualTanHandleEnabledIn = false
    public var isManualTanHandleEnabledOut = false
    
    public var storedUserDragTanDirectionIn = Float(0.0)
    public var storedUserDragTanDirectionOut = Float(0.0)
    public var storedUserDragTanMagnitudeIn = ControlPoint.defaultTanLength
    public var storedUserDragTanMagnitudeOut = ControlPoint.defaultTanLength
    
    public var isTanHandleModified = false
    
    public var point: Math.Point {
        Math.Point(x: x, y: y)
    }
    
    public func disableManualTanHandle() {
        isManualTanHandleEnabledIn = false
        isManualTanHandleEnabledOut = false
    }
    
    public func setManualTanHandleIn(direction: Float,
                                     magnitude: Float,
                                     isManualTanMelded: Bool) {
        tanDirectionIn = direction
        isManualTanHandleEnabledIn = true
        if isManualTanMelded {
            tanDirectionOut = tanDirectionIn
            isManualTanHandleEnabledOut = true
        }
        
        tanMagnitudeIn = magnitude
        isTanHandleModified = true
        storedUserDragTanDirectionIn = tanDirectionIn
        storedUserDragTanDirectionOut = tanDirectionOut
        storedUserDragTanMagnitudeIn = tanMagnitudeIn
        storedUserDragTanMagnitudeOut = tanMagnitudeOut
    }
    
    public func setManualTanHandleOut(direction: Float,
                                      magnitude: Float,
                                      isManualTanMelded: Bool) {
        tanDirectionOut = -direction
        isManualTanHandleEnabledOut = true
        if isManualTanMelded {
            tanDirectionIn = tanDirectionOut
            isManualTanHandleEnabledIn = true
        }
        
        tanMagnitudeOut = magnitude
        isTanHandleModified = true
        storedUserDragTanDirectionIn = tanDirectionIn
        storedUserDragTanDirectionOut = tanDirectionOut
        storedUserDragTanMagnitudeIn = tanMagnitudeIn
        storedUserDragTanMagnitudeOut = tanMagnitudeOut
    }
    
    public func getTanHandleIn() -> Math.Point {
        return Math.Point(x: x - sinf(tanDirectionIn) * tanMagnitudeIn,
                          y: y + cosf(tanDirectionIn) * tanMagnitudeIn)
    }
    
    public func getTanHandleOut() -> Math.Point {
        return Math.Point(x: x + sinf(tanDirectionOut) * tanMagnitudeOut,
                          y: y - cosf(tanDirectionOut) * tanMagnitudeOut)
    }
    
    public func getTanHandleNormalsIn() -> Math.Vector {
        return Math.Vector(x: cosf(tanDirectionIn),
                           y: sinf(tanDirectionIn))
    }
    
    public func getTanHandleNormalsOut() -> Math.Vector {
        return Math.Vector(x: cosf(tanDirectionOut),
                           y: sinf(tanDirectionOut))
    }
    
    private func attemptAngleFromTansIn(inTanX: Float,
                                       inTanY: Float,
                                       tanFactor: Float) {
        
        var inDist = inTanX * inTanX + inTanY * inTanY
        
        let epsilon = Float(0.1 * 0.1)
        
        var rotation = Float(0.0)
        var isValidReading = true
        
        if inDist > epsilon {
            rotation = Math.face(target: .init(x: -inTanX, y: -inTanY))
        } else {
            isValidReading = false
        }
        
        if inDist > Math.epsilon {
            inDist = sqrtf(inDist)
        }
        
        if isValidReading {
            tanDirectionIn = rotation
            tanMagnitudeIn = inDist * tanFactor
        }
        
    }
    
    private func attemptAngleFromTansOut(outTanX: Float,
                                         outTanY: Float,
                                         tanFactor: Float) {
        var outDist = outTanX * outTanX + outTanY * outTanY
        let epsilon = Float(0.1 * 0.1)
        var rotation = Float(0.0)
        var isValidReading = true
        if outDist > epsilon {
            rotation = Math.face(target: .init(x: outTanX, y: outTanY))
        } else {
            isValidReading = false
        }
        
        if outDist > Math.epsilon {
            outDist = sqrtf(outDist)
        }
        
        if isValidReading {
            tanDirectionOut = rotation
            tanMagnitudeOut = outDist * tanFactor
        }
    }
    
    public func attemptAngleFromTansUnknown(inTanX: Float,
                                            inTanY: Float,
                                            outTanX: Float,
                                            outTanY: Float,
                                            tanFactor: Float) {
        if isManualTanHandleEnabledIn == false {
            attemptAngleFromTansIn(inTanX: inTanX, inTanY: inTanY, tanFactor: tanFactor)
        }
        if isManualTanHandleEnabledOut == false {
            attemptAngleFromTansOut(outTanX: outTanX, outTanY: outTanY, tanFactor: tanFactor)
        }
    }
    
    public func getData() -> ControlPointData {
        var result = ControlPointData()
        result.x = self.x
        result.y = self.y
        result.tanDirectionIn = self.tanDirectionIn
        result.tanDirectionOut = self.tanDirectionOut
        result.tanMagnitudeIn = self.tanMagnitudeIn
        result.tanMagnitudeOut = self.tanMagnitudeOut
        result.isManualTanHandleEnabledIn = self.isManualTanHandleEnabledIn
        result.isManualTanHandleEnabledOut = self.isManualTanHandleEnabledOut
        return result
    }
    
    public func setData(_ controlPointData: ControlPointData) {
        self.x = controlPointData.x
        self.y = controlPointData.y
        self.tanDirectionIn = controlPointData.tanDirectionIn
        self.tanDirectionOut = controlPointData.tanDirectionOut
        self.tanMagnitudeIn = controlPointData.tanMagnitudeIn
        self.tanMagnitudeOut = controlPointData.tanMagnitudeOut
        self.isManualTanHandleEnabledIn = controlPointData.isManualTanHandleEnabledIn
        self.isManualTanHandleEnabledOut = controlPointData.isManualTanHandleEnabledOut
    }
}

public struct ControlPointData {
    
    public init() {
        
    }
    
    public var x = Float(0.0)
    public var y = Float(0.0)
    
    public var tanDirectionIn = Float(0.0)
    public var tanDirectionOut = Float(0.0)
    public var tanMagnitudeIn = ControlPoint.defaultTanLength
    public var tanMagnitudeOut = ControlPoint.defaultTanLength
    
    public var isManualTanHandleEnabledIn = false
    public var isManualTanHandleEnabledOut = false
    
    public mutating func copy(_ data: ControlPointData) {
        self.x = data.x
        self.y = data.y
        
        self.tanDirectionIn = data.tanDirectionIn
        self.tanDirectionOut = data.tanDirectionOut
        self.tanMagnitudeIn = data.tanMagnitudeIn
        self.tanMagnitudeOut = data.tanMagnitudeOut
        
        self.isManualTanHandleEnabledIn = data.isManualTanHandleEnabledIn
        self.isManualTanHandleEnabledOut = data.isManualTanHandleEnabledOut
    }
    
}

