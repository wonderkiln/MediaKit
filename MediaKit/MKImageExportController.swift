//
//  MKImageExportController.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 12/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public protocol MKImageExportController {
    var originalImage: UIImage? { get set }
    func export(_ callback: @escaping (UIImage) -> Void)
}

public protocol MKVideoExportController {
    var originalURL: URL? { get set }
    func export(_ callback: @escaping (URL) -> Void)
}
