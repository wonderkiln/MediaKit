//
//  UIImage+WebP.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 07/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import YYImage

public extension UIImage {
    
    public func webp_Data(quality: CGFloat = 1.0) -> Data? {
        let encoder = YYImageEncoder(type: .webP)
        encoder?.quality = quality
        encoder?.add(self, duration: 0)
        return encoder?.encode()
    }
}
