//
//  File.swift
//  
//
//  Created by Mario Rúa on 1/11/23.
//

import Foundation
import SceneKit

extension SCNVector3 {
    static func +(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x + right.x, left.y + right.y, left.z + right.z)
    }
    
    static func -(left: SCNVector3, right: SCNVector3) -> SCNVector3 {
        return SCNVector3(left.x - right.x, left.y - right.y, left.z - right.z)
    }
    
    static func cross(_ a: SCNVector3, _ b: SCNVector3) -> SCNVector3 {
      return SCNVector3(a.y * b.z - a.z * b.y,
        a.z * b.x - a.x * b.z,
        a.x * b.y - a.y * b.x)
    }

    func normalized() -> SCNVector3 {
      let length = sqrt(x * x + y * y + z * z)
      return SCNVector3(x / length, y / length, z / length)
    }
}
