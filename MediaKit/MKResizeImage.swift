//
//  MKResizeImage.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 05/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit
import ImageIO
import AVFoundation

public class MKResizeImage: MKProtocol {
    
    public var displayName: String = "Resize"
    
    public var size: CGSize
    public var fill: Bool
    
    public init(toSize size: CGSize, fillImage fill: Bool) {
        self.size = size
        self.fill = fill
    }
    
    public func apply<InputType : MKInputType>(to input: InputType, _ completion: @escaping (InputType, Error?) -> Void) {
        guard let media = input as? MKImageType else {
            return completion(input, MKError("`MKResizeImage` only works with `MKImageType` types"))
        }
        
        let scale = UIScreen.main.scale
        let rect = CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
        var aspectSize = AVMakeRect(aspectRatio: media.image.size, insideRect: rect).size
        let data = UIImagePNGRepresentation(media.image) as! CFData
        
        if fill {
            if aspectSize.width < size.width * scale {
                let ratio = size.width / aspectSize.width * scale
                aspectSize = CGSize(width: aspectSize.width * ratio,
                                    height: aspectSize.height * ratio)
            } else if aspectSize.height < size.height * scale {
                let ratio = size.height / aspectSize.height * scale
                aspectSize = CGSize(width: aspectSize.width * ratio,
                                    height: aspectSize.height * ratio)
            }
        }
        
        guard let imageSource = CGImageSourceCreateWithData(data, nil) else {
            return completion(input, MKError(""))
        }
        
        let options: [NSString: Any] = [
            kCGImageSourceThumbnailMaxPixelSize: max(aspectSize.width, aspectSize.height),
            kCGImageSourceCreateThumbnailFromImageAlways: true,
            kCGImageSourceCreateThumbnailWithTransform: true,
            kCGImageSourceShouldAllowFloat: true
        ]
        
        guard let thumbnailSource = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options as CFDictionary) else {
            return completion(input, MKError(""))
        }
        
        let thumbnail = UIImage(cgImage: thumbnailSource)
        completion(MKImageType(thumbnail) as! InputType, nil)
    }
}
