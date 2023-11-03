//
//  File.swift
//  
//
//  Created by Mario Rúa on 1/11/23.
//

import Foundation
import ARKit
import SceneKit

protocol LuminosityReporting: AnyObject {
    func luminosityUpdated(_ value: CGFloat)
}

@available(iOS 11.0, *)
class FullFaceSceneViewManager: NSObject, ARSCNViewDelegate {
    var eyeshadowNode: SCNNode!
    var eyelinesNode: SCNNode!
    var lipsNode: SCNNode!
    var normalSource: SCNGeometrySource!
    var sceneType: ARFilterViewController.CallType
    weak var luminosityDelegate: LuminosityReporting?
    
    public init(sceneType: ARFilterViewController.CallType) {
        self.sceneType = sceneType
    }
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return nil }
        guard case .filter(_, _) = sceneType else { return nil }

        let geometry = faceAnchor.geometry
        
        // Calculate normals for smooth shading
        var normals = [SCNVector3](repeating: SCNVector3(0, 0, 0), count: geometry.vertices.count)
        for i in stride(from: 0, to: geometry.triangleIndices.count, by: 3) {
            let v1 = geometry.vertices[Int(geometry.triangleIndices[i])]
            let v2 = geometry.vertices[Int(geometry.triangleIndices[i + 1])]
            let v3 = geometry.vertices[Int(geometry.triangleIndices[i + 2])]
            
            let normal = SCNVector3.cross(SCNVector3(v2) - SCNVector3(v1), SCNVector3(v3) - SCNVector3(v1)).normalized() // Calculate normal for the triangle
            normals[Int(geometry.triangleIndices[i])] = normals[Int(geometry.triangleIndices[i])] + normal
            normals[Int(geometry.triangleIndices[i + 1])] = normals[Int(geometry.triangleIndices[i + 1])] + normal
            normals[Int(geometry.triangleIndices[i + 2])] = normals[Int(geometry.triangleIndices[i + 2])] + normal
        }
        
        // Normalize the normals
        for i in 0..<normals.count {
            normals[i] = normals[i].normalized()
        }
        
        normalSource = SCNGeometrySource(normals: normals)
        
        let verticesSource = SCNGeometrySource(vertices: geometry.vertices.map { .init($0) })
        let coordinatesSource = SCNGeometrySource(textureCoordinates: geometry.textureCoordinates.map {
            CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))
        })
        let element = SCNGeometryElement(indices: geometry.triangleIndices, primitiveType: .triangles)
        
        let faceGeometry = SCNGeometry(sources: [verticesSource, coordinatesSource], elements: [element])
        
        let faceNode = SCNNode()
        faceNode.simdTransform = faceAnchor.transform
        
        eyeshadowNode = SCNNode(geometry: faceGeometry)
        eyelinesNode = SCNNode(geometry: faceGeometry)
        lipsNode = SCNNode(geometry: faceGeometry)
        
        faceNode.addChildNode(eyeshadowNode)
        faceNode.addChildNode(eyelinesNode)
        faceNode.addChildNode(lipsNode)
        
        return faceNode
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        guard case .filter(_, _) = sceneType else { return }
        
        let geometry = faceAnchor.geometry
        
        let verticesSource = SCNGeometrySource(vertices: geometry.vertices.map { .init($0) })
        let coordinatesSource = SCNGeometrySource(textureCoordinates: geometry.textureCoordinates.map {
            CGPoint(x: CGFloat($0.x), y: CGFloat($0.y))
        })
        let element = SCNGeometryElement(indices: geometry.triangleIndices, primitiveType: .triangles)
        
        //let faceGeometry = SCNGeometry(sources: [verticesSource, coordinatesSource], elements: [element])
        
        let eyeshadowGeometry = SCNGeometry(sources: [verticesSource, coordinatesSource, normalSource], elements: [element])
        eyeshadowGeometry.materials = [Materials.eyeshadowMaterial]
        eyeshadowNode.geometry = eyeshadowGeometry
        
        let eyelinesGeometry = SCNGeometry(sources: [verticesSource, coordinatesSource, normalSource], elements: [element])
        eyelinesGeometry.materials = [Materials.eyelinerMaterial]
        eyelinesNode.geometry = eyelinesGeometry
        
        let lipsGeometry = SCNGeometry(sources: [verticesSource, coordinatesSource, normalSource], elements: [element])
        lipsGeometry.materials = [Materials.lipsMaterial]
        lipsNode.geometry = lipsGeometry
        
        //node.geometry = faceGeometry
        node.simdTransform = faceAnchor.transform
    }
}

@available(iOS 11.0, *)
extension FullFaceSceneViewManager: ARSessionDelegate {
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        guard let faceLight = session.currentFrame?.lightEstimate as? ARDirectionalLightEstimate else {
            return
        }
        
        luminosityDelegate?.luminosityUpdated(faceLight.primaryLightIntensity)
    }
}

