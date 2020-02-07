//
//  CameraButton.swift
//  CameraButton
//
//  Created by Anton on 11.01.2020.
//  Copyright © 2020 Anton Lovchikov. All rights reserved.
//

import UIKit

class CameraButton: UIButton {
    
    // Config
    private let borderColor = UIColor.white
    private let activeColor = UIColor(red: 245/255, green: 107/255, blue: 99/255, alpha: 1)
    private let disabledColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.7)
    private let borderPadding = CGFloat(1)
    private let borderWidth = CGFloat(2)
    private let knobPadding = CGFloat(5)
    private let knobCornerRadius = CGFloat(8)
    private let recordingIndicatorPadding = CGFloat(-24)
    private let recordingIndicatorMinScaleTransform = CATransform3DMakeScale(0.5, 0.5, 0.5)
    private let recordingIndicator1MaxScaleTransform = CATransform3DMakeScale(1.0, 1.0, 1.0)
    private let recordingIndicator2MaxScaleTransform = CATransform3DMakeScale(1.1, 1.1, 1.1)
    private let knobMinScaleTransform = CATransform3DMakeScale(0.6, 0.6, 0.6)
    private let knobMaxScaleTransform = CATransform3DMakeScale(1.2, 1.2, 1.2)
    private let pulseAnimationTimingFunction = CAMediaTimingFunction(controlPoints: 0.3, 0.0, 0.1, 1.0)
    private let pulseAnimationDuration = 1.0
    // Elements
    private var borderLayer = CALayer()
    private var knobLayer = CALayer()
    private var recordingIndicatorLayer1 = CALayer()
    private var recordingIndicatorLayer2 = CALayer()

    override func awakeFromNib() {
        // Set up actions
        self.addTarget(self, action: #selector(self.touchBegan), for: UIControl.Event.touchDown)
        self.addTarget(self, action: #selector(self.touchBegan), for: UIControl.Event.touchDragEnter)
        self.addTarget(self, action: #selector(self.touchEnded), for: UIControl.Event.touchCancel)
        self.addTarget(self, action: #selector(self.touchEnded), for: UIControl.Event.touchDragExit)
        self.addTarget(self, action: #selector(self.touchEnded), for: UIControl.Event.touchUpOutside)
        self.addTarget(self, action: #selector(self.clicked), for: UIControl.Event.touchUpInside)
        
        // Add elements
        self.layer.addSublayer(borderLayer)
        self.layer.addSublayer(recordingIndicatorLayer1)
        self.layer.addSublayer(recordingIndicatorLayer2)
        self.layer.addSublayer(knobLayer)
        
        // Set up Border Layer
        borderLayer.frame = CGRect(x: borderPadding, y: borderPadding, width: self.frame.width - borderPadding * 2 , height: self.frame.height - borderPadding * 2)
        borderLayer.cornerRadius = borderLayer.frame.width / 2
        borderLayer.borderWidth = borderWidth
        borderLayer.borderColor = borderColor.cgColor
        
        // Set up Knob Layer
        knobLayer.frame = CGRect(x: knobPadding, y: knobPadding, width: self.frame.width - knobPadding * 2 , height: self.frame.height - knobPadding * 2)
        knobLayer.cornerRadius = knobLayer.frame.width / 2
        knobLayer.backgroundColor = activeColor.cgColor
        
        // Set up Recording Indicator Layer - 1
        recordingIndicatorLayer1.frame = CGRect(x: recordingIndicatorPadding, y: recordingIndicatorPadding, width: self.frame.width - recordingIndicatorPadding * 2 , height: self.frame.height - recordingIndicatorPadding * 2)
        recordingIndicatorLayer1.cornerRadius = recordingIndicatorLayer1.frame.width / 2
        recordingIndicatorLayer1.backgroundColor = activeColor.withAlphaComponent(0.5).cgColor
        recordingIndicatorLayer1.opacity = 0
        
        // Set up Recording Indicator Layer - 2
        recordingIndicatorLayer2.frame = recordingIndicatorLayer1.frame
        recordingIndicatorLayer2.cornerRadius = recordingIndicatorLayer2.frame.width / 2
        recordingIndicatorLayer2.backgroundColor = activeColor.withAlphaComponent(0.5).cgColor
        recordingIndicatorLayer2.opacity = 0
        
        // Set them into initial position
        recordingIndicatorLayer1.transform = recordingIndicatorMinScaleTransform
        recordingIndicatorLayer2.transform = recordingIndicatorMinScaleTransform
    }
    
    @objc func touchBegan() {
        highlight()
    }
    
    @objc func touchEnded() {
        normalize()
    }
    
    @objc func clicked() {
        self.isSelected.toggle()
    }
    
    override var isSelected: Bool {
        didSet {
            if isSelected {
                borderLayer.opacity = 0
                knobLayer.transform = knobMinScaleTransform
                knobLayer.cornerRadius = knobCornerRadius
                knobLayer.backgroundColor = borderColor.cgColor
                pulseRecordingIndicator()
            } else {
                knobLayer.backgroundColor = activeColor.cgColor
                normalize()
                knobLayer.cornerRadius = knobLayer.frame.width / 2
            }
        }
    }
    
    private func highlight() {
        borderLayer.opacity = 0
        recordingIndicatorLayer1.opacity = 1
        recordingIndicatorLayer2.opacity = 1
        knobLayer.transform = knobMaxScaleTransform
    }
    
    private func normalize() {
        borderLayer.opacity = 1
        recordingIndicatorLayer1.opacity = 0
        recordingIndicatorLayer2.opacity = 0
        knobLayer.transform = CATransform3DMakeScale(1.0, 1.0, 1.0)
        recordingIndicatorLayer1.removeAllAnimations()
        recordingIndicatorLayer2.removeAllAnimations()
        recordingIndicatorLayer1.transform = recordingIndicatorMinScaleTransform
        recordingIndicatorLayer2.transform = recordingIndicatorMinScaleTransform
    }

    private func pulseRecordingIndicator() {
        if isHighlighted {
            let indicatorAnim = CABasicAnimation(keyPath: #keyPath(CALayer.transform))
            indicatorAnim.fillMode = .forwards
            indicatorAnim.autoreverses = true
            indicatorAnim.repeatCount = Float.greatestFiniteMagnitude
            indicatorAnim.timingFunction = pulseAnimationTimingFunction
            indicatorAnim.duration = pulseAnimationDuration
            indicatorAnim.fromValue = recordingIndicatorMinScaleTransform
            indicatorAnim.toValue = recordingIndicator1MaxScaleTransform
            recordingIndicatorLayer1.add(indicatorAnim, forKey: "scale")
            
            let indicator2Anim = indicatorAnim
            indicator2Anim.toValue = recordingIndicator2MaxScaleTransform
            indicator2Anim.beginTime = CACurrentMediaTime() + pulseAnimationDuration / 2.0
            recordingIndicatorLayer2.add(indicator2Anim, forKey: "scale")

        }
    }
}
