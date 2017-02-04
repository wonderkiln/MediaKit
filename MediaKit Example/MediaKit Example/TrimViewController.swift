//
//  TrimViewController.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 13/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit
import MobileCoreServices
import MediaKit

class TrimViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let picker = UIImagePickerController()
        picker.videoMaximumDuration = 20
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.delegate = self
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let url = info[UIImagePickerControllerMediaURL] as? URL {
            addVideoTrimmer(url: url)
            print(url)
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    var trimVideoController: MKTrimVideoViewController!
    
    func addVideoTrimmer(url: URL) {
        let vc = MKTrimVideoViewController(url: url)
        vc.view.frame = view.bounds
        view.insertSubview(vc.view, at: 0)
        addChildViewController(vc)
        vc.didMove(toParentViewController: self)
        
        self.trimVideoController = vc
    }
}
