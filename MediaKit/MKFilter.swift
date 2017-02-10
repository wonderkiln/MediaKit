//
//  MKFilter.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 10/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit

public struct MKFilterProperty {
    
    public var displayName: String
    public var propertyKey: String
    public var minimum: Float = 0
    public var maximum: Float = 1
    public var value: Float = 0.5
    
    public init(name: String, key: String, value: Float, minimum: Float, maximum: Float) {
        self.displayName = name
        self.propertyKey = key
        self.value = value
        self.minimum = minimum
        self.maximum = maximum
    }
}

public struct MKFilter {
    
    public var displayName: String
    public var filter: CIFilter
    
    public init(name: String, filterName: String) {
        self.filter = CIFilter(name: filterName)!
        self.displayName = name
    }
    
    public var properties: [MKFilterProperty] {
        let inputNames = filter.inputKeys.filter { parameterName -> Bool in
            return parameterName != "inputImage"
        }
        
        let attributes = filter.attributes
        
        return inputNames.flatMap { inputName -> MKFilterProperty? in
            let attribute = attributes[inputName] as! [String: Any]
            
            guard let minValue = attribute[kCIAttributeSliderMin] as? Float,
                let maxValue = attribute[kCIAttributeSliderMax] as? Float,
                let defaultValue = attribute[kCIAttributeDefault] as? Float else {
                    return nil
            }
            
            let name = inputName.substring(from: inputName.index(inputName.startIndex, offsetBy: 5))
            return MKFilterProperty(name: name, key: inputName, value: defaultValue, minimum: minValue, maximum: maxValue)
        }
    }
}
