//
//  File.swift
//  
//
//  Created by Mario Rúa on 1/11/23.
//

import Foundation
import UIKit

extension UIImage {
    public static func pixel(ofColor color: UIColor) -> UIImage {
        let pixel = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        
        UIGraphicsBeginImageContext(pixel.size)
        defer { UIGraphicsEndImageContext() }
        
        guard let context = UIGraphicsGetCurrentContext() else { return UIImage() }
        
        context.setFillColor(color.cgColor)
        context.fill(pixel)
        
        return UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
    }
    
    func tint(with color: UIColor) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else {
            return self
        }
        defer { UIGraphicsEndImageContext() }
        
        draw(at: .zero, blendMode: .normal, alpha: 1.0)
        context.setFillColor(color.cgColor)
        context.setBlendMode(.sourceAtop)
        context.fill(CGRect(origin: .zero, size: size))
        
        if let tintedImage = UIGraphicsGetImageFromCurrentImageContext() {
            return tintedImage
        }
        return self
    }
}

