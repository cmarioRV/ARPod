//
//  BundleManager.swift
//  ARPod
//
//  Created by Mario Rúa on 2/11/23.
//

import Foundation

final class BundleManager {
    static let resourceBundle: Bundle = {
        let myBundle = Bundle(for: BundleManager.self)
        guard let resourceBundleURL = myBundle.url(
            forResource: "ARPod", withExtension: "bundle")
            else { fatalError("ARPod.bundle not found!") }
        guard let resourceBundle = Bundle(url: resourceBundleURL)
            else { fatalError("Cannot access ARPod.bundle!") }
        return resourceBundle
    }()
}
