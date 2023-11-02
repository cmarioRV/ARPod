//
//  File.swift
//  
//
//  Created by Mario Rúa on 1/11/23.
//

import SceneKit

struct Materials {
    static let eyeshadowMaterial: SCNMaterial = {
      let material = SCNMaterial()
      material.diffuse.contents = UIImage(named: "eyeshadowMaterial.png")?.tint(with: .systemPurple)
      material.lightingModel = .physicallyBased
      material.transparency = 0.8
      return material
    }()

    static let eyelinerMaterial: SCNMaterial = {
      let material = SCNMaterial()
      material.diffuse.contents = UIImage(named: "eyelinerMaterial.png")?.tint(with: .black)
      material.lightingModel = .physicallyBased
      material.transparency = 0.8
      return material
    }()

    static let lipsMaterial: SCNMaterial = {
      let material = SCNMaterial()
      material.diffuse.contents = UIImage(named: "lipsMaterial.png")?.tint(with: .systemRed)
      material.lightingModel = .physicallyBased
      material.transparency = 0.8
      return material
    }()
}
