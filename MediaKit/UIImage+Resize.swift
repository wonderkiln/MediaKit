//
//  UIImage+Resize.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 10/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit

public extension UIImage {
    
    public func resize(aspectFill size: CGSize) -> UIImage? {
        let scale = UIScreen.main.scale
        let fromRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let toRect = CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
        
        let rect = aspectFill(fromRect: fromRect, toRect: toRect)
        
        UIGraphicsBeginImageContextWithOptions(toRect.size, false, scale)
        self.draw(in: rect)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    public func resize(aspectFit size: CGSize) -> UIImage? {
        let scale = UIScreen.main.scale
        let fromRect = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        let toRect = CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
        
        let rect = aspectFit(fromRect: fromRect, toRect: toRect)
        
        UIGraphicsBeginImageContextWithOptions(toRect.size, false, scale)
        self.draw(in: rect)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
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
}
