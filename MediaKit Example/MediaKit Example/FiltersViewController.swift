//
//  ViewController.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 04/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

class FiltersViewController: UIViewController {

    @IBOutlet weak var filteredImageView: MKFilteredImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var adjustView: UIView! {
        didSet {
            adjustView.isHidden = true
        }
    }
    
    fileprivate let filters: [MKFilter] = [
        MKFilter(name: "Chrome", filterName: "CIPhotoEffectChrome"),
        MKFilter(name: "Fade", filterName: "CIPhotoEffectFade"),
        MKFilter(name: "Instant", filterName: "CIPhotoEffectInstant"),
        MKFilter(name: "Mono", filterName: "CIPhotoEffectMono"),
        MKFilter(name: "Process", filterName: "CIPhotoEffectProcess"),
        MKFilter(name: "Sepia", filterName: "CISepiaTone"),
        MKFilter(name: "Vignette", filterName: "CIVignette"),
        MKFilter(name: "Photo Transfer", filterName: "CIPhotoEffectTransfer"),
        MKFilter(name: "Tonal", filterName: "CIPhotoEffectTonal"),
        MKFilter(name: "Invert", filterName: "CIColorInvert"),
        MKFilter(name: "Vibrance", filterName: "CIVibrance"),
    ]
    
    fileprivate var filterProperties: [MKFilterProperty] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    fileprivate var filterImage: UIImage? {
        didSet {
            filteredImages = Array(repeating: nil, count: filters.count)
            
            if let filterImage = filterImage, let image = CIImage(image: filterImage) {
                DispatchQueue.global(qos: .background).async {
                    self.filters.enumerated().forEach { [unowned self] (index, filter) in
                        filter.filter.setValue(image, forKey: kCIInputImageKey)
                        if let image = filter.filter.outputImage {
                            let finalImage = UIImage(ciImage: image)
                            self.filteredImages[index] = finalImage
                            
                            DispatchQueue.main.async {
                                let indexPath = IndexPath(row: index, section: 0)
                                if let cell = self.collectionView.cellForItem(at: indexPath) as? FilterCollectionViewCell {
                                    cell.imageView.image = finalImage
                                }
                            }
                        }
                    }
                }
            }
            
            collectionView.reloadData()
        }
    }
    
    fileprivate var filteredImages: [UIImage?] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        filteredImageView.inputImage = #imageLiteral(resourceName: "Picture")
        filterImage = #imageLiteral(resourceName: "Picture").resize(aspectFill: CGSize(width: 100, height: 100))
    }
    
    @IBAction func didTapAdjustButton(_ sender: UIBarButtonItem) {
        adjustView.isHidden = !adjustView.isHidden
    }
}

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}

public protocol MKFilterPropertyDelegate: class {
    func filterPropertyDidChange(_ property: MKFilterProperty)
}

extension MKFilteredImageView: MKFilterPropertyDelegate {
    
    public func filterPropertyDidChange(_ property: MKFilterProperty) {
        self.filter?.setValue(property.value, forKey: property.propertyKey)
        self.setNeedsDisplay()
    }
}

class FilterPropertyTablesViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    
    weak var delegate: MKFilterPropertyDelegate?
    
    var property: MKFilterProperty? {
        didSet {
            if let property = property {
                titleLabel.text = property.displayName
                valueSlider.minimumValue = property.minimum
                valueSlider.maximumValue = property.maximum
                valueSlider.value = property.value
            }
        }
    }
    
    @IBAction func didChangeValueSlider(_ slider: UISlider) {
        if var property = property {
            property.value = slider.value
            delegate?.filterPropertyDidChange(property)
        }
    }
}

extension FiltersViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterProperties.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterPropertyTablesViewCell",
                                                 for: indexPath) as! FilterPropertyTablesViewCell
        
        cell.property = filterProperties[indexPath.row]
        cell.delegate = filteredImageView
        
        return cell
    }
}

extension FiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell",
                                                      for: indexPath) as! FilterCollectionViewCell
        
        cell.imageView.image = filteredImages[indexPath.row]
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        filteredImageView.filter = filter.filter
        filterProperties = filter.properties
    }
}
