//
//  MKFilter.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 05/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit
import CoreImage

public protocol MKFilter: MKProtocol {
    var filter: CIFilter { get set }
}

extension MKFilter {
    
    public func apply<InputType : MKInputType>(to input: InputType, _ completion: @escaping (InputType, Error?) -> Void) {
        guard let media = input as? MKImageType else {
            return completion(input, MKError("`MKFilter` only works with `MKImageType` types"))
        }
        
        let inputImage = CIImage(image: media.image)
        filter.setValue(inputImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else {
            return completion(input, MKError( ""))
        }
        
        let options = [
            kCIContextUseSoftwareRenderer: false
        ]
        let context = CIContext(options: options)
        
        guard let finalImage = context.createCGImage(outputImage, from: outputImage.extent) else {
            return completion(input, MKError(""))
        }
        
        let image = UIImage(cgImage: finalImage)
        completion(MKImageType(image) as! InputType, nil)
    }
}
