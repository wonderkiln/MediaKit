//
//  MKProtocol.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 05/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public protocol MKInputType { }

public class MKImageType: MKInputType {
    public var image: UIImage
    
    public init(_ image: UIImage) {
        self.image = image
    }
}

public class MKVideoType: MKInputType {
    public var url: URL
    
    public init(_ url: URL) {
        self.url = url
    }
}

public struct MKError: Error {
    public var message: String
    
    public var localizedDescription: String {
        return message
    }
    
    public init(_ message: String) {
        self.message = message
    }
}

public protocol MKProtocol {
    var displayName: String { get set }
    typealias Completion<InputType: MKInputType> = (InputType, Error?) -> Void
    func apply<InputType: MKInputType>(to input: InputType, _ completion: @escaping Completion<InputType>)
}
