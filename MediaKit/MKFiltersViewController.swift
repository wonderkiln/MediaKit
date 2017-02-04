//
//  MKFiltersViewController.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 09/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public class MKFiltersViewController: UIViewController, MKImageExportController {
    
    @IBOutlet public weak var imageView: UIImageView!
    @IBOutlet public weak var indicatorContainerView: UIView! {
        didSet {
            indicatorContainerView.isHidden = true
        }
    }
    @IBOutlet public weak var indicatorView: UIActivityIndicatorView!
    @IBOutlet public weak var collectionView: UICollectionView!
    @IBOutlet public weak var bottomLayoutConstraint: NSLayoutConstraint!
    
    private class MKEmpty: MKProtocol {
        
        var displayName: String = "None"
        
        func apply<InputType : MKInputType>(to input: InputType, _ completion: @escaping (InputType, Error?) -> Void) {
            completion(input, nil)
        }
    }
    
    public var filters: [MKProtocol] = [
        MKEmpty(),
        MKMonoFilter(),
        MKSepiaFilter(),
        MKInstantFilter(),
        MKChromeFilter(),
        MKFadeFilter(),
        MKProcessFilter(),
        MKVignetteFilter(),
        MKPhotoTransferFilter(),
        MKTonalFilter(),
        MKInvertFilter(),
    ] {
        didSet {
            filteredImages = Array(repeating: nil, count: filters.count)
        }
    }
    
    fileprivate var selectedEffect: MKProtocol?
    
    public var afterEffects: [MKProtocol] = [
        MKResizeImage(toSize: CGSize(width: 1080, height: 1920), fillImage: true)
    ]
    
    public func export(_ completion: @escaping (UIImage) -> Void) {
        guard let originalImage = originalImage else {
            return
        }
        guard let selectedEffect = selectedEffect else {
            return
        }
        
        var effects: [MKProtocol] = [selectedEffect]
        effects.append(contentsOf: afterEffects)
        
        let effect = MKMultipleEffects(effects)
        effect.apply(to: MKImageType(originalImage)) { (output, error) in
            completion(output.image)
        }
    }
    
    fileprivate var filteredImages: [UIImage?] = [] {
        didSet {
            collectionView?.reloadData()
        }
    }
    
    public var originalImage: UIImage? {
        didSet {
            if let originalImage = originalImage {
                scaleOriginalImage(originalImage)
            }
        }
    }
    
    fileprivate var scaledImage: UIImage?
    
    public init() {
        super.init(nibName: "MKFiltersViewController", bundle: Bundle(for: MKFiltersViewController.self))
    }
    
    public init(image: UIImage) {
        self.originalImage = image
        super.init(nibName: "MKFiltersViewController", bundle: Bundle(for: MKFiltersViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        let nib = UINib(nibName: "MKFilterCollectionViewCell",
                        bundle: Bundle(for: MKFilterCollectionViewCell.self))
        collectionView.register(nib, forCellWithReuseIdentifier: MKFilterCollectionViewCell.identifier)
        
        filteredImages = Array(repeating: nil, count: filters.count)
        
        if let originalImage = originalImage {
            scaleOriginalImage(originalImage)
        }
    }
    
    fileprivate var isBusy: Bool = false {
        didSet {
            collectionView.isUserInteractionEnabled = !isBusy
            indicatorContainerView.isHidden = !isBusy
            isBusy ?
                indicatorView.startAnimating() :
                indicatorView.stopAnimating()
        }
    }
    
    fileprivate func scaleOriginalImage(_ image: UIImage) {
        isBusy = true
        
        let effect = MKMultipleEffects([
            MKResizeImage(toSize: imageView.frame.size, fillImage: false)
        ])
        effect.apply(to: MKImageType(image)) { (output, error) in
            self.scaledImage = output.image
            self.imageView.image = output.image
            self.isBusy = false
            self.updateAllFilterImages()
        }
    }
    
    fileprivate func updateAllFilterImages() {
        guard let scaledImage = scaledImage else {
            return
        }
        
        filters.enumerated().forEach { (index, filter) in
            updateFilterImage(scaledImage, atIndex: index, withFilter: filter)
        }
    }
    
    fileprivate func updateFilterImage(_ image: UIImage, atIndex index: Int, withFilter filter: MKProtocol) {
        MKMultipleEffects([filter]).apply(to: MKImageType(image), { (output, error) in
            self.filteredImages[index] = output.image
            self.collectionView.reloadItems(at: [IndexPath(row: index, section: 0)])
        })
    }
}

extension MKFiltersViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filteredImages.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MKFilterCollectionViewCell.identifier,
                                                      for: indexPath) as! MKFilterCollectionViewCell
        
        let filter = filters[indexPath.row]
        
        cell.setImage(filteredImages[indexPath.row])
        cell.nameLabel.text = filter.displayName
        cell.tag = indexPath.row
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedEffect = filters[indexPath.row]
        if let image = filteredImages[indexPath.row] {
            imageView.image = image
        }
    }
}
