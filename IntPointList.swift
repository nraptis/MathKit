//
//  WaveIslandIntPointList.swift
//  Yo Mamma Be Ugly
//
//  Created by Nick Raptis on 2/20/24.
//

import Foundation

public class IntPointList {
    
    public private(set) var capacity = 0
    public private(set) var count = 0
    
    public private(set) var x = [Int]()
    public private(set) var y = [Int]()
    
    public init() {
        
    }
    
    public func add(_ x: Int, _ y: Int) {
        if count >= capacity {
            reserveCapacity(minimumCapacity: count + (count >> 1) + 1)
        }
        self.x[count] = x
        self.y[count] = y
        count += 1
    }
    
    public func reserveCapacity(minimumCapacity: Int) {
        if minimumCapacity > capacity {
            x.reserveCapacity(minimumCapacity)
            y.reserveCapacity(minimumCapacity)
            while x.count < minimumCapacity { x.append(0) }
            while y.count < minimumCapacity { y.append(0) }
            capacity = minimumCapacity
        }
    }
    
    public func removeAll(keepingCapacity: Bool) {
        if keepingCapacity == false {
            x.removeAll(keepingCapacity: false)
            y.removeAll(keepingCapacity: false)
            capacity = 0
        }
        count = 0
    }
}
