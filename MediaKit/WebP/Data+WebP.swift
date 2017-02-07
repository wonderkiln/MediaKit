//
//  Data+WebP.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 07/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import YYImage

public extension Data {
    
    public func webp_Image() -> UIImage? {
        let decoder = YYImageDecoder(data: self, scale: UIScreen.main.scale)
        let image = decoder?.frame(at: 0, decodeForDisplay: true)?.image
        
        if let image = image {
            return image
        }
        
        return UIImage(data: self)
    }
}
