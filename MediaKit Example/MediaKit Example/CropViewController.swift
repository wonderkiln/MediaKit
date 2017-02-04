//
//  CropViewController.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 09/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit
import MediaKit

class CropViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cropViewController = MKCropViewController(image: #imageLiteral(resourceName: "Picture"))
        cropViewController.view.frame = view.bounds
        view.addSubview(cropViewController.view)
        self.addChildViewController(cropViewController)
        cropViewController.didMove(toParentViewController: self)
    }
}
