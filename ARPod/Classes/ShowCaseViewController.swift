// The Swift Programming Language
// https://docs.swift.org/swift-book

import UIKit
import ARKit
import SwiftUI
import Combine
import QuartzCore

@available(iOS 13.0, *)
public class ShowCaseViewController: UIViewController {
    private var arView: ARSCNView = ARSCNView(frame: .zero)
    private var sceneDelegate = FullFaceSceneViewManager(sceneType: .colorSensing)
    private let luminosityWarningView = UnsuitableLuminosityWarningView()
    private let luminosityBuffer = CircularBuffer(size: 10)
    private var minLuminosity: CGFloat = 1000
    private var maxLuminosity: CGFloat = 4000
    private var cameraView = UIView()
    
    private lazy var settingsView = ShowCaseSettingsView(onSelect: {
        switch $1 {
        case .eyeLiner:
            Materials.eyelinerMaterial.diffuse.contents = UIImage(named: "eyelinerMaterial.png")?.tint(with: $0)
        case .eyeShadow:
            Materials.eyeshadowMaterial.diffuse.contents = UIImage(named: "eyeshadowMaterial.png")?.tint(with: $0)
        case .lips:
            Materials.lipsMaterial.diffuse.contents = UIImage(named: "lipsMaterial.png")?.tint(with: $0)
        }
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    })
    
    private let luminosityLabel: UILabel = {
        let label = UILabel()
        label.font = .monospacedSystemFont(ofSize: 8, weight: .regular)
        label.numberOfLines = 1
        label.textAlignment = .left
        label.textColor = .white
        return label
    }()
    
    private let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("¡Let's start!", for: .normal)
        button.tintColor = .white
        button.setBackgroundImage(.pixel(ofColor: .systemBlue), for: .normal)
        button.layer.cornerRadius = 20
        button.layer.masksToBounds = true
        return button
    }()
    
    private enum Constants {
        // Distance between faceOverlayBox.minY and view.center.y
        static let faceOverlayViewCenterOffsetY = 250.0
    }
    
    private lazy var faceOverlayBox: CGRect = {
        let faceWidthToHeightRatio = 0.6
        let screenFactor = 0.8
        let radius = self.view.center.x * screenFactor
        let yCenterOffset = self.view.center.y - Constants.faceOverlayViewCenterOffsetY
        let rect = CGRect(origin: .init(x: self.view.center.x - radius, y: yCenterOffset), size: .init(width: radius * 2, height: radius * 2 / faceWidthToHeightRatio))
        return rect
    }()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "Show case"
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape.fill"), style: .plain, target: self, action: #selector(didTapSettingsButton))
        
        setupARView()
        setupStartButton()
        setupLuminosityLabel()
        setupLuminosityWarningView()
        setupFaceOverlayView()
        sceneDelegate.luminosityDelegate = self
    }
    
    private func setupARView() {
        arView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(arView)
        
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            arView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            arView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            arView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
        arView.delegate = sceneDelegate
        arView.session.delegate = sceneDelegate
        arView.session.run(makeARTrackingConfiguration())
    }
    
    private func setupLuminosityLabel() {
        view.addSubview(luminosityLabel)
        luminosityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            luminosityLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            luminosityLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -5),
            luminosityLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -5)
        ])
    }
    
    private func setupLuminosityWarningView() {
        view.addSubview(luminosityWarningView)
        luminosityWarningView.isHidden = true
        luminosityWarningView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            luminosityWarningView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            luminosityWarningView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            luminosityWarningView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
        
        luminosityWarningView.layoutIfNeeded()
    }
    
    private func setupStartButton() {
        startButton.addTarget(self, action: #selector(didTapStartButton), for: .touchUpInside)
        view.addSubview(startButton)
        startButton.setBackgroundColor(.init(hex: "#EA899A"), for: .normal)
        startButton.setBackgroundColor(.gray, for: .disabled)
        startButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            startButton.heightAnchor.constraint(equalToConstant: 50),
            startButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 50),
            startButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            startButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -50)
        ])
    }
    
    private func setupFaceOverlayView() {
        addSilhouette(cameraView)
        view.addSubview(cameraView)
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            cameraView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            cameraView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])
        
        cameraView.isHidden = true
    }
    
    private func makeARTrackingConfiguration() -> ARConfiguration {
        let configuration = ARFaceTrackingConfiguration()
        if ARFaceTrackingConfiguration.isSupported {
            configuration.maximumNumberOfTrackedFaces = 1
        }
        return configuration
    }
    
    @objc func didTapStartButton(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.cameraView.isHidden = false
            self.startButton.isHidden = true
        }
    }
    
    @objc func didTapSettingsButton() {
        navigationController?.present(UIHostingController(rootView: settingsView), animated: true)
    }
    
    private func deg2rad(_ number: Double) -> CGFloat{
        return CGFloat(number * Double.pi / 180)
    }
    
    private func addSilhouette(_ cameraView: UIView){
        let path = UIBezierPath(roundedRect: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height), cornerRadius: 0)
        
        let radius = faceOverlayBox.width / 2
        
        // Semicircle for the silhouette
        let semicircle = UIBezierPath(arcCenter: CGPoint(x: faceOverlayBox.midX, y: faceOverlayBox.minY + radius), radius: radius, startAngle: deg2rad(0), endAngle: deg2rad(180), clockwise: false)

        // Chin area of the silhouette
        let freeform = UIBezierPath()
        freeform.move(to: CGPoint(x: faceOverlayBox.minX, y: faceOverlayBox.minY + radius))
        freeform.addCurve(to: CGPoint(x: faceOverlayBox.maxX, y: faceOverlayBox.minY + radius), controlPoint1: CGPoint(x: faceOverlayBox.minX - 10, y: faceOverlayBox.maxY), controlPoint2: CGPoint(x: faceOverlayBox.maxX + 10, y: faceOverlayBox.maxY))

        path.append(semicircle)
        path.append(freeform)
        path.usesEvenOddFillRule = true
        
        let fillLayer = CAShapeLayer()
        fillLayer.path = path.cgPath
        //fillLayer.fillRule = .evenOdd
        fillLayer.opacity = 0.7
        cameraView.layer.addSublayer(fillLayer)
    }
}

@available(iOS 13.0, *)
extension ShowCaseViewController: LuminosityReporting {
    func luminosityUpdated(_ value: CGFloat) {
        DispatchQueue.main.async {
            guard let luminosity = self.luminosityBuffer.add(value: value) else {
                return
            }
            self.luminosityLabel.text = "Lumens: \(String(format: "%.0f", luminosity))"
            
            let luminosityAboveMin = luminosity > self.minLuminosity
            let luminosityBelowMax = luminosity < self.maxLuminosity
            self.luminosityWarningView.isHidden = luminosityAboveMin && luminosityBelowMax
            self.startButton.isEnabled = luminosityAboveMin && luminosityBelowMax
            
            if !luminosityAboveMin {
                self.luminosityWarningView.configure(.init(title: "Low illumination. Please move to a brighter location and try again"))
            }
            
            if !luminosityBelowMax {
                self.luminosityWarningView.configure(.init(title: "High illumination. Please move to a less illuminated place and try again."))
            }
        }
    }
}
