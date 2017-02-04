//
//  ViewController.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 04/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit
import MediaKit

class FiltersViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filtersViewController = MKFiltersViewController(image: #imageLiteral(resourceName: "Picture"))
        filtersViewController.view.frame = view.bounds
        view.addSubview(filtersViewController.view)
        self.addChildViewController(filtersViewController)
        filtersViewController.didMove(toParentViewController: self)
        filtersViewController.imageView.contentMode = .scaleAspectFill
    }
}
