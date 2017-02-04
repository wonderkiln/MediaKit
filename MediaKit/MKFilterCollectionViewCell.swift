//
//  MKFilterCollectionViewCell.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 09/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public class MKFilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet public weak var imageView: UIImageView!
    @IBOutlet public weak var nameLabel: UILabel!
    @IBOutlet public weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet public weak var selectionView: UIView! {
        didSet {
            selectionView.layer.borderColor = UIColor.white.cgColor
            selectionView.layer.borderWidth = 3
            selectionView.isHidden = true
        }
    }
    
    public static var identifier: String {
        return String(describing: MKFilterCollectionViewCell.self)
    }
    
    public override var isSelected: Bool {
        didSet {
            selectionView.isHidden = !isSelected
        }
    }
    
    public func setImage(_ image: UIImage?) {
        imageView.image = image
        image == nil ?
            indicatorView.startAnimating() :
            indicatorView.stopAnimating()
    }
}
