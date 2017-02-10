//
//  MKFilteredImageView.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 10/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import CoreImage
import GLKit
import OpenGLES

open class MKFilteredImageView: GLKView {
    
    public var filter: CIFilter? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var inputImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var outputImage: UIImage? {
        guard let inputImage = inputImage, let inputCIImage = CIImage(image: inputImage) else {
            return nil
        }
        
        guard let filter = filter else {
            return nil
        }
        
        filter.setValue(inputCIImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else {
            return nil
        }
        
        return UIImage(ciImage: outputImage)
    }
    
    private var ciContext: CIContext!
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open func commonInit() {
        clipsToBounds = true
        enableSetNeedsDisplay = true
        context = EAGLContext(api: .openGLES3)
        ciContext = CIContext(eaglContext: context)
    }
    
    override open func draw(_ rect: CGRect) {
        clearBackground()
        
        guard let inputImage = inputImage, let inputCIImage = CIImage(image: inputImage) else {
            return
        }
        
        var outputImage: CIImage?
        
        if let filter = filter {
            filter.setValue(inputCIImage, forKey: kCIInputImageKey)
            outputImage = filter.outputImage
        }
        
        if outputImage == nil {
            outputImage = inputCIImage
        }
        
        let inputBounds = inputCIImage.extent
        let drawableBounds = CGRect(x: 0, y: 0, width: self.drawableWidth, height: self.drawableHeight)
        let targetBounds = imageBoundsForContentMode(fromRect: inputBounds, toRect: drawableBounds)
        ciContext.draw(outputImage!, in: targetBounds, from: inputBounds)
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    private func clearBackground() {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        glClearColor(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    private func aspectFit(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        }
        
        return fitRect.integral
    }
    
    private func aspectFill(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.width = toRect.size.height  * fromAspectRatio
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        } else {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        }
        
        return fitRect.integral
    }
    
    private func imageBoundsForContentMode(fromRect: CGRect, toRect: CGRect) -> CGRect {
        switch contentMode {
        case .scaleAspectFill:
            return aspectFill(fromRect: fromRect, toRect: toRect)
        case .scaleAspectFit:
            return aspectFit(fromRect: fromRect, toRect: toRect)
        default:
            return fromRect
        }
    }
}
