//
//  ConversionViewController.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 07/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import MediaKit

class ConversionViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let image = #imageLiteral(resourceName: "Picture")
        if let data = image.webp_Data() {
            print(ByteCountFormatter.string(fromByteCount: Int64(data.count), countStyle: .binary))
            imageView.image = data.webp_Image()
        }
    }
}
