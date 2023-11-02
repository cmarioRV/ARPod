//
//  File.swift
//  
//
//  Created by Mario Rúa on 1/11/23.
//

import Foundation

class CircularBuffer {
    var buffer: [CGFloat]
    var sum: CGFloat
    var index: Int
    var count: Int
    
    init(size: Int) {
        buffer = Array(repeating: 0, count: size)
        sum = 0
        index = 0
        count = 0
    }
    
    func add(value: CGFloat) -> Double? {
        sum += value - buffer[index]
        buffer[index] = value
        index = (index + 1) % buffer.count
        count += 1
        if count < buffer.count {
            return nil
        }
        return Double(sum) / Double(buffer.count)
    }
}
