//
//  BorderTool.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 11/26/24.
//

import Foundation

public class BorderTool {
    
    public init() {
        
    }
    
    private static let CLEAN_THRESHOLD = Float(1.0)
    private static let CLEAN_THRESHOLD_SQUARED = CLEAN_THRESHOLD * CLEAN_THRESHOLD
    
    static let SAMPLES_PER_POINT_LOW_FI = 8
    private static let SAMPLES_PER_POINT_LOW_FI_1 = (SAMPLES_PER_POINT_LOW_FI - 1)
    
    static let SAMPLES_PER_POINT_MED_FI = 32
    private static let SAMPLES_PER_POINT_MED_FI_1 = (SAMPLES_PER_POINT_MED_FI - 1)
    
    static let SAMPLES_PER_POINT_BIG_FI = 128
    private static let SAMPLES_PER_POINT_BIG_FI_1 = (SAMPLES_PER_POINT_BIG_FI - 1)
    
    public func build(spline: FancySpline,
                      preferredStepSize: Float,
                      skipInterpolationDistance: Float,
                      lowFiSampleDistance: Float,
                      medFiSampleDistance: Float) {
        
        borderCount = 0
        sampleCount = 0
        cleanCount = 0
        
        let lastIndex = (spline.maxIndex - 1)
        for index in 0..<spline.maxIndex {
            
            let skipFirstPoint = (index != 0)
            let skipLastPoint = (index == lastIndex)
            
            sampleLowFi(spline: spline, index: index)
            
            let sampleLength = getSampleLength()
            if sampleLength < skipInterpolationDistance {
                
                // That's the next border point?
                if index == lastIndex {
                    addPointBorder(x: sampleX[Self.SAMPLES_PER_POINT_LOW_FI_1],
                                   y: sampleY[Self.SAMPLES_PER_POINT_LOW_FI_1],
                                   index: 0)
                } else {
                    addPointBorder(x: sampleX[Self.SAMPLES_PER_POINT_LOW_FI_1],
                                   y: sampleY[Self.SAMPLES_PER_POINT_LOW_FI_1],
                                   index: index + 1)
                }
            } else {
                if sampleLength > medFiSampleDistance {
                    sampleBigFi(spline: spline, index: index)
                } else if sampleLength > lowFiSampleDistance {
                    sampleMedFi(spline: spline, index: index)
                }
                proceedBuildWithGoodSample(spline: spline,
                                           controlIndex: index,
                                           lastControlIndex: lastIndex,
                                           preferredStepSize: preferredStepSize,
                                           skipFirstPoint: skipFirstPoint,
                                           skipLastPoint: skipLastPoint)
            }
        }
    }
    
    private func proceedBuildWithGoodSample(spline: FancySpline,
                                            controlIndex: Int,
                                            lastControlIndex: Int,
                                            preferredStepSize: Float,
                                            skipFirstPoint: Bool,
                                            skipLastPoint: Bool) {
        
        if sampleCount < Self.SAMPLES_PER_POINT_LOW_FI {
            return
        }
        
        if preferredStepSize <= 2.0 {
            return
        }
        
        
        
        // So there is a problem here.
        // For eample, the point could cut straight through the
        // final point, and yet the loop be large.
        
        // So we need to walk backwards.
        let lastX = sampleX[sampleCount - 1]
        let lastY = sampleY[sampleCount - 1]
        
        var index = sampleCount - 2
        while index >= 0 {
            let currentX = sampleX[index]
            let currentY = sampleY[index]
            let diffX = currentX - lastX
            let diffY = currentY - lastY
            let distanceSquared = diffX * diffX + diffY * diffY
            if distanceSquared >= Self.CLEAN_THRESHOLD_SQUARED {
                break
            }
            index -= 1
        }
        
        // This is now the last index we should consider;
        // Everything beyond this index is bunched up
        // with the final point (micro loops???)
        let cleanSeekMaxIndex = index
        
        if cleanSeekMaxIndex <= 0 {
            // In this case, all the points are
            // bunched up... We just take 1 point,
            // probably an illegal spline...
            addPointBorder(x: sampleX[0],
                           y: sampleY[0],
                           index: controlIndex)
            return
        }
        
        cleanCount = 0
        
        // We add the first point. We are going to for
        // sure use the first point and the last point...
        var runningLength = Float(0.0)
        addPointClean(x: sampleX[0], y: sampleY[0], length: runningLength)
        
        var previousX = sampleX[0]
        var previousY = sampleY[0]
        
        index = 1
        while index <= cleanSeekMaxIndex {
            let currentX = sampleX[index]
            let currentY = sampleY[index]
            let diffX = currentX - previousX
            let diffY = currentY - previousY
            let distanceSquared = diffX * diffX + diffY * diffY
            if distanceSquared >= Self.CLEAN_THRESHOLD_SQUARED {
                let distance = sqrtf(distanceSquared)
                runningLength += distance
                
                addPointClean(x: currentX,
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
            cleanX[cleanCount - 1] = lastX
            cleanY[cleanCount - 1] = lastX
        } else {
            let distance = sqrtf(distanceSquared)
            runningLength += distance
            
            addPointClean(x: lastX,
                          y: lastY,
                          length: runningLength)
        }
        
        // In all cases, we take the first point if
        
        if skipFirstPoint == false {
            addPointBorder(x: sampleX[0],
                           y: sampleY[0],
                           index: controlIndex)
        }
        
        var numberOfPoints = 1
        if runningLength > preferredStepSize {
            numberOfPoints = (Int((runningLength / preferredStepSize) + 0.5))
            
            var loop = 1
            while loop < numberOfPoints {
                
                let loopPercent = Float(loop) / Float(numberOfPoints)
                let distance = loopPercent * runningLength
                
                let upperBound = upperBoundClean(distance: distance)
                let upperBound1 = upperBound - 1
                
                let distanceLo = cleanLength[upperBound1]
                let distanceHi = cleanLength[upperBound]
                let deltaDistance = (distanceHi - distanceLo)
                let percent = (distance - distanceLo) / deltaDistance
                
                let interpolatedX = cleanX[upperBound1] + (cleanX[upperBound] - cleanX[upperBound1]) * percent
                let interpolatedY = cleanY[upperBound1] + (cleanY[upperBound] - cleanY[upperBound1]) * percent
                
                addPointBorder(x: interpolatedX,
                               y: interpolatedY,
                               index: controlIndex)
                
                loop += 1
            }
        }
        
        if skipLastPoint == false {
            var finalIndex: Int
            if controlIndex == lastControlIndex {
                finalIndex = 0
            } else {
                finalIndex = controlIndex + 1
            }
            addPointBorder(x: sampleX[sampleCount - 1],
                           y: sampleY[sampleCount - 1],
                           index: finalIndex)
        }
        
    }
    
    private func getSampleLength() -> Float {
        if sampleCount > 1 {
            
            var result = Float(0.0)
            var previousX = sampleX[0]
            var previousY = sampleY[0]
            var sampleIndex = 1
            while sampleIndex < sampleCount {
                let currentX = sampleX[sampleIndex]
                let currentY = sampleY[sampleIndex]
                let diffX = currentX - previousX
                let diffY = currentY - previousY
                let distanceSquared = diffX * diffX + diffY * diffY
                if distanceSquared > Math.epsilon {
                    let distance = sqrtf(distanceSquared)
                    result += distance
                }
                previousX = currentX
                previousY = currentY
                sampleIndex += 1
            }
            return result
        } else {
            return 0.0
        }
    }
    
    private func sampleLowFi(spline: FancySpline, index: Int) {
        sampleCount = 0
        for percentIndex in 0..<BorderTool.SAMPLES_PER_POINT_LOW_FI {
            let percent = Float(percentIndex) / Float(BorderTool.SAMPLES_PER_POINT_LOW_FI_1)
            let x = spline.getX(index: index, percent: percent)
            let y = spline.getY(index: index, percent: percent)
            addPointSample(x: x, y: y)
        }
    }
    
    private func sampleMedFi(spline: FancySpline, index: Int) {
        sampleCount = 0
        for percentIndex in 0..<BorderTool.SAMPLES_PER_POINT_MED_FI {
            let percent = Float(percentIndex) / Float(BorderTool.SAMPLES_PER_POINT_MED_FI_1)
            let x = spline.getX(index: index, percent: percent)
            let y = spline.getY(index: index, percent: percent)
            addPointSample(x: x, y: y)
        }
    }
    
    private func sampleBigFi(spline: FancySpline, index: Int) {
        sampleCount = 0
        for percentIndex in 0..<BorderTool.SAMPLES_PER_POINT_BIG_FI {
            let percent = Float(percentIndex) / Float(BorderTool.SAMPLES_PER_POINT_BIG_FI_1)
            let x = spline.getX(index: index, percent: percent)
            let y = spline.getY(index: index, percent: percent)
            addPointSample(x: x, y: y)
        }
    }
    
    private func reset() {
        borderCount = 0
        sampleCount = 0
        cleanCount = 0
    }
    
    // The x and y as, stepSize constrained, possibly self-intersecting. (step ii)
    public private(set) var borderCount = 0
    public private(set) var borderCapacity = 0
    public private(set) var borderX = [Float]()
    public private(set) var borderY = [Float]()
    public private(set) var borderIndex = [Int]()
    
    public func addPointBorder(x: Float,
                               y: Float,
                               index: Int) {
        if borderCount >= borderCapacity {
            reserveCapacityBorder(minimumCapacity: borderCount + (borderCount >> 1) + 1)
        }
        borderX[borderCount] = x
        borderY[borderCount] = y
        borderIndex[borderCount] = index
        borderCount += 1
    }
    
    private func reserveCapacityBorder(minimumCapacity: Int) {
        if minimumCapacity > borderCapacity {
            borderX.reserveCapacity(minimumCapacity)
            borderY.reserveCapacity(minimumCapacity)
            borderIndex.reserveCapacity(minimumCapacity)
            while borderX.count < minimumCapacity {
                borderX.append(0.0)
            }
            while borderY.count < minimumCapacity {
                borderY.append(0.0)
            }
            while borderIndex.count < minimumCapacity {
                borderIndex.append(1)
            }
            borderCapacity = minimumCapacity
        }
    }
    
    
    // The x and y as, stepSize constrained, possibly self-intersecting. (step ii)
    private var sampleCount = 0
    private var sampleCapacity = 0
    private var sampleX = [Float]()
    private var sampleY = [Float]()
    
    public func addPointSample(x: Float, y: Float) {
        if sampleCount >= sampleCapacity {
            reserveCapacitySample(minimumCapacity: sampleCount + (sampleCount >> 1) + 1)
        }
        sampleX[sampleCount] = x
        sampleY[sampleCount] = y
        sampleCount += 1
    }
    
    private func reserveCapacitySample(minimumCapacity: Int) {
        if minimumCapacity > sampleCapacity {
            sampleX.reserveCapacity(minimumCapacity)
            sampleY.reserveCapacity(minimumCapacity)
            while sampleX.count < minimumCapacity {
                sampleX.append(0.0)
            }
            while sampleY.count < minimumCapacity {
                sampleY.append(0.0)
            }
            sampleCapacity = minimumCapacity
        }
    }
    
    private(set) var cleanCount = 0
    private var cleanCapacity = 0
    private var cleanX = [Float]()
    private var cleanY = [Float]()
    private var cleanLength = [Float]()
    
    private func upperBoundClean(distance: Float) -> Int {
        var start = 0
        var end = cleanCount
        while start != end {
            let mid = (start + end) >> 1
            if distance >= cleanLength[mid] {
                start = mid + 1
            } else {
                end = mid
            }
        }
        return start
    }
    
    private func addPointClean(x: Float, y: Float, length: Float) {
        if cleanCount >= cleanCapacity {
            reserveCapacityClean(minimumCapacity: cleanCount + (cleanCount >> 1) + 1)
        }
        cleanX[cleanCount] = x
        cleanY[cleanCount] = y
        cleanLength[cleanCount] = length
        cleanCount += 1
    }
    
    private func reserveCapacityClean(minimumCapacity: Int) {
        if minimumCapacity > cleanCapacity {
            cleanX.reserveCapacity(minimumCapacity)
            cleanY.reserveCapacity(minimumCapacity)
            cleanLength.reserveCapacity(minimumCapacity)
            while cleanX.count < minimumCapacity { cleanX.append(0.0) }
            while cleanY.count < minimumCapacity { cleanY.append(0.0) }
            while cleanLength.count < minimumCapacity { cleanLength.append(0.0) }
            cleanCapacity = minimumCapacity
        }
    }
    
}
