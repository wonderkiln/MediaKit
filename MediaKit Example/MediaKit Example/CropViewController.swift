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
    
    private var cropViewController: MKCropViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let cropViewController = MKCropViewController()
        cropViewController.view.frame = view.bounds
        cropViewController.view.frame.size.height -= 64
        view.addSubview(cropViewController.view)
        self.addChildViewController(cropViewController)
        cropViewController.didMove(toParentViewController: self)
        cropViewController.image = #imageLiteral(resourceName: "Picture")
        self.cropViewController = cropViewController
    }
    
    @IBAction func didTapCropButton(_ sender: UIBarButtonItem) {
        if let image = cropViewController.cropView?.croppedImage {
            cropViewController.image = image
        }
    }
}
