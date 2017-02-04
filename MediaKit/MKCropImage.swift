//
//  MKCropEffect.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 10/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public class MKCropImage: MKProtocol {
    
    public var displayName: String = "Crop"
    
    public var relativeRect: CGRect
    
    public init(relativeRect: CGRect) {
        self.relativeRect = relativeRect
    }
    
    public func apply<InputType : MKInputType>(to input: InputType, _ completion: @escaping (InputType, Error?) -> Void) {
        guard let media = input as? MKImageType else {
            return completion(input, MKError("`MKFilter` only works with `MKImageType` types"))
        }
        guard let imageCg = media.image.cgImage else {
            return completion(input, MKError(""))
        }
        
        let absoluteRect = CGRect(x: media.image.size.width * relativeRect.origin.x,
                                  y: media.image.size.height * relativeRect.origin.y,
                                  width: media.image.size.width * relativeRect.width,
                                  height: media.image.size.height * relativeRect.height)
        
        guard let imageRef = imageCg.cropping(to: absoluteRect) else {
            return completion(input, MKError(""))
        }
        
        let image = UIImage(cgImage: imageRef)
        completion(MKImageType(image) as! InputType, nil)
    }
}
