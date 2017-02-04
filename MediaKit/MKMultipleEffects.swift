//
//  MKMultipleEffects.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 05/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public class MKMultipleEffects: MKProtocol {
    
    public var displayName: String = "Multiple"
    
    public var effects: [MKProtocol]
    
    public init(_ effects: [MKProtocol]) {
        self.effects = effects
    }
    
    fileprivate var isCanceled: Bool = false
    
    public func apply<InputType : MKInputType>(to input: InputType, _ completion: @escaping (InputType, Error?) -> Void) {
        
        func applyEffects(_ effects: [MKProtocol], to input: InputType, _ completion: @escaping (InputType, Error?) -> Void) {
            if isCanceled { return }
            
            guard let effect = effects.first else {
                return DispatchQueue.main.async {
                    completion(input, nil)
                }
            }
            
            effect.apply(to: input) { (output, error) in
                if let error = error {
                    return completion(input, error)
                }
                applyEffects(Array(effects.dropFirst()), to: output, completion)
            }
        }
        
        DispatchQueue.global(qos: .background).async {
            applyEffects(self.effects, to: input, completion)
        }
    }
    
    public func cancel() {
        isCanceled = true
    }
}
