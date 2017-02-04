//
//  MKMaskView.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 11/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public class MKMaskView: UIView {
    
    public var maskFrame: CGRect = CGRect.zero {
        didSet {
            if maskFrame.isEmpty {
                layer.mask = nil
                return
            }
            
            updateMaskWithRect(maskFrame)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open func commonInit() {
        //
    }
    
    fileprivate func updateMaskWithRect(_ rect: CGRect) {
        let path = CGMutablePath()
        path.addRect(rect)
        path.addRect(bounds)
        
        let maskLayer = CAShapeLayer()
        maskLayer.path = path
        maskLayer.fillRule = kCAFillRuleEvenOdd
        layer.mask = maskLayer
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateMaskWithRect(maskFrame)
    }
}
