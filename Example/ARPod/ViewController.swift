//
//  ViewController.swift
//  ARPod
//
//  Created by Mario Vargas on 11/01/2023.
//  Copyright (c) 2023 Mario Vargas. All rights reserved.
//

import UIKit
import ARPod

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let arViewController = ARFilterViewController(viewModel: .init(lowLight: .lowLight(limit: 1000, warningMessage: "Low light warning"), highLight: .highLight(limit: 4000, warningMessage: "High light warning")), callType: .colorSensing)
        self.navigationController?.pushViewController(arViewController, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

