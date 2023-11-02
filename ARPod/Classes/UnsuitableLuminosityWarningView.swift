//
//  File.swift
//  
//
//  Created by Mario Rúa on 1/11/23.
//

import Foundation
import UIKit

class UnsuitableLuminosityWarningView: UIView {
    lazy var warningLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        return label
    }()
    
    var warningBackgroundView: UIView = {
       let backgroundView = UIView()
        backgroundView.backgroundColor = .init(hex: "#EA899A")
        backgroundView.layer.opacity = 0.5
        return backgroundView
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureLayout() {
        backgroundColor = .clear
        layer.cornerRadius = 10
        layer.masksToBounds = true
        
        addSubview(warningBackgroundView)
        warningBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            warningBackgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            warningBackgroundView.trailingAnchor.constraint(equalTo: trailingAnchor),
            warningBackgroundView.topAnchor.constraint(equalTo: topAnchor),
            warningBackgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(warningLabel)
        warningLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            warningLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10),
            warningLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            warningLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            warningLabel.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
    
    public func configure(_ viewModel: ViewModel) {
        warningLabel.text = viewModel.title
        layoutIfNeeded()
    }
}

extension UnsuitableLuminosityWarningView {
    struct ViewModel {
        let title: String
    }
}

