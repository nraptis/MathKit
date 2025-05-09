//
//  InterpolatingPath.swift
//  ChannelWizard
//
//  Created by Nick Raptis on 1/22/24.
//

import Foundation

public class OutlinePath {
    
    public init() {
        
    }
    
    private static let safeThreshold = Float(1.0)
    private static let safeThresholdSquared = safeThreshold * safeThreshold
    
    // The x and y as they are added in, with no modifications.
    private(set) var baseCount = 0
    private var _baseCapacity = 0
    private var _baseX = [Float]()
    private var _baseY = [Float]()
    
    // The main idea behind safe is to prevent any 2 "hugged up" points. e.g. distance ~ 0.0...
    private(set) var safeCount = 0
    private var _safeCapacity = 0
    private var _safeX = [Float]()
    private var _safeY = [Float]()
    private var _safeLength = [Float]()
    
    // When we "read," we "read" the whole thing at once into this list...
    public private(set) var count = 0
    private var _readCapacity = 0
    public private(set) var x = [Float]()
    public private(set) var y = [Float]()
    
    public func solve(step: Float,
               skipFirstPoint: Bool,
               skipLastPoint: Bool) {
        
        removeAllRead(keepingCapacity: true)
        removeAllSafe(keepingCapacity: true)
        
        if baseCount <= 0 {
            return
        }
        
        if baseCount == 1 {
            addPointSafe(x: _baseX[0], y: _baseY[0], length: 0.0)
            addPointRead(x: _safeX[0], y: _safeX[0])
            return
        }

        // So there is a problem here.
        // For eample, the point could cut straight through the
        // final point, and yet the loop be large.

        // So we need to walk backwards.
        let lastX = _baseX[baseCount - 1]
        let lastY = _baseY[baseCount - 1]

        var index = baseCount - 2
        while index >= 0 {
            let currentX = _baseX[index]
            let currentY = _baseY[index]
            let diffX = currentX - lastX
            let diffY = currentY - lastY
            let distanceSquared = diffX * diffX + diffY * diffY
            if distanceSquared >= Self.safeThresholdSquared {
                break
            }
            index -= 1
        }

        // This is now the last index we should consider;
        // Everything beyond this index is bunched up
        // with the final point (micro loops???)
        let safeSeekMaxIndex = index

        if safeSeekMaxIndex <= 0 {
            // In this case, all the points are
            // bunched up... We just take 1 point,
            // probably an illegal spline...
            addPointRead(x: _baseX[0],
                           y: _baseY[0])
            return
        }

        safeCount = 0

        // We add the first point. We are going to for
        // sure use the first point and the last point...
        var runningLength = Float(0.0)
        addPointSafe(x: _baseX[0],
                     y: _baseY[0],
                     length: runningLength)

        var previousX = _baseX[0]
        var previousY = _baseY[0]

        index = 1
        while index <= safeSeekMaxIndex {
            let currentX = _baseX[index]
            let currentY = _baseY[index]
            let diffX = currentX - previousX
            let diffY = currentY - previousY
            let distanceSquared = diffX * diffX + diffY * diffY
            if distanceSquared >= Self.safeThresholdSquared {
                let distance = sqrtf(distanceSquared)
                runningLength += distance
                
                addPointSafe(x: currentX,
                              y: currentY,
                              length: runningLength)
                
                previousX = currentX
                previousY = currentY
            }
            index += 1
        }

        let diffX = lastX - previousX
        let diffY = lastY - previousY
        let distanceSquared = diffX * diffX + diffY * diffY
        if distanceSquared < Math.epsilon {
            _safeX[safeCount - 1] = lastX
            _safeY[safeCount - 1] = lastX
            
        } else {
            let distance = sqrtf(distanceSquared)
            runningLength += distance
            
            addPointSafe(x: lastX,
                          y: lastY,
                          length: runningLength)
        }

        // In all cases, we take the first point if
        if skipFirstPoint == false {
            addPointRead(x: _baseX[0],
                         y: _baseY[0])
        }
        
        
        var numberOfPoints = 1
        if runningLength > step {
            numberOfPoints = (Int((runningLength / step) + 0.5))
            
            var loop = 1
            while loop < numberOfPoints {
                
                let loopPercent = Float(loop) / Float(numberOfPoints)
                let distance = loopPercent * runningLength
                
                let upperBound = upperBoundSafe(distance: distance)
                let upperBound1 = upperBound - 1
                
                let distanceLo = _safeLength[upperBound1]
                let distanceHi = _safeLength[upperBound]
                let deltaDistance = (distanceHi - distanceLo)
                let percent = (distance - distanceLo) / deltaDistance
                
                let interpolatedX = _safeX[upperBound1] + (_safeX[upperBound] - _safeX[upperBound1]) * percent
                let interpolatedY = _safeY[upperBound1] + (_safeY[upperBound] - _safeY[upperBound1]) * percent
                
                addPointRead(x: interpolatedX,
                               y: interpolatedY)
                
                loop += 1
            }
            
        }

        if skipLastPoint == false {
            addPointRead(x: _baseX[baseCount - 1],
                           y: _baseY[baseCount - 1])
        }
    }
    
    private func upperBoundSafe(distance: Float) -> Int {
        var start = 0
        var end = safeCount
        while start != end {
            let mid = (start + end) >> 1
            if distance >= _safeLength[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
    }
    
    public func addPoint(x: Float, y: Float) {
        if (baseCount + 1) >= _baseCapacity {
            reserveCapacityBase(minimumCapacity: baseCount + (baseCount >> 1) + 2)
        }
        _baseX[baseCount] = x
        _baseY[baseCount] = y
        baseCount += 1
    }
    
    private func addPointSafe(x: Float, y: Float, length: Float) {
        if safeCount >= _safeCapacity {
            reserveCapacitySafe(minimumCapacity: safeCount + (safeCount >> 1) + 1)
        }
        _safeX[safeCount] = x
        _safeY[safeCount] = y
        _safeLength[safeCount] = length
        safeCount += 1
    }
    
    private func addPointRead(x: Float, y: Float) {
        if (count + 1) >= _readCapacity {
            reserveCapacityRead(minimumCapacity: count + (count >> 1) + 2)
        }
        self.x[count] = x
        self.y[count] = y
        count += 1
    }
    
    private func reserveCapacityBase(minimumCapacity: Int) {
        if minimumCapacity > _baseCapacity {
            _baseX.reserveCapacity(minimumCapacity)
            _baseY.reserveCapacity(minimumCapacity)
            while _baseX.count < minimumCapacity { _baseX.append(0.0) }
            while _baseY.count < minimumCapacity { _baseY.append(0.0) }
            _baseCapacity = minimumCapacity
        }
    }
    
    private func reserveCapacitySafe(minimumCapacity: Int) {
        if minimumCapacity > _safeCapacity {
            _safeX.reserveCapacity(minimumCapacity)
            _safeY.reserveCapacity(minimumCapacity)
            _safeLength.reserveCapacity(minimumCapacity)
            while _safeX.count < minimumCapacity { _safeX.append(0.0) }
            while _safeY.count < minimumCapacity { _safeY.append(0.0) }
            while _safeLength.count < minimumCapacity { _safeLength.append(0.0) }
            _safeCapacity = minimumCapacity
        }
    }
    
    private func reserveCapacityRead(minimumCapacity: Int) {
        if minimumCapacity > _readCapacity {
            x.reserveCapacity(minimumCapacity)
            y.reserveCapacity(minimumCapacity)
            while x.count < minimumCapacity { x.append(0.0) }
            while y.count < minimumCapacity { y.append(0.0) }
            _readCapacity = minimumCapacity
        }
    }
    
    public func removeAll(keepingCapacity: Bool) {
        removeAllBase(keepingCapacity: keepingCapacity)
        removeAllSafe(keepingCapacity: keepingCapacity)
        removeAllRead(keepingCapacity: keepingCapacity)
    }
    
    private func removeAllBase(keepingCapacity: Bool) {
        if keepingCapacity == false {
            _baseX.removeAll(keepingCapacity: false)
            _baseY.removeAll(keepingCapacity: false)
            _baseCapacity = 0
        }
        baseCount = 0
    }
    
    private func removeAllSafe(keepingCapacity: Bool) {
        if keepingCapacity == false {
            _safeX.removeAll(keepingCapacity: false)
            _safeY.removeAll(keepingCapacity: false)
            _safeLength.removeAll(keepingCapacity: false)
            _safeCapacity = 0
        }
        safeCount = 0
    }
    
    private func removeAllRead(keepingCapacity: Bool) {
        if keepingCapacity == false {
            x.removeAll(keepingCapacity: false)
            y.removeAll(keepingCapacity: false)
            _readCapacity = 0
        }
        count = 0
    }
}
