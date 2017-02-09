//
//  ViewController.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 04/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit
import CoreImage
import GLKit
import OpenGLES

public struct FilterProperty {
    
    public var displayName: String
    public var propertyKey: String
    public var minimum: Float = 0
    public var maximum: Float = 1
    public var value: Float = 0.5
    
    public init(name: String, key: String, value: Float, minimum: Float, maximum: Float) {
        self.displayName = name
        self.propertyKey = key
        self.value = value
        self.minimum = minimum
        self.maximum = maximum
    }
}

public protocol FilterPropertyDelegate: class {
    func filterPropertyDidChange(_ property: FilterProperty)
}

public struct Filter {
    
    public var displayName: String
    public var filter: CIFilter
    
    public init(name: String, filterName: String) {
        self.filter = CIFilter(name: filterName)!
        self.displayName = name
    }
    
    public var properties: [FilterProperty] {
        let inputNames = filter.inputKeys.filter { parameterName -> Bool in
            return parameterName != "inputImage"
        }
        
        let attributes = filter.attributes
        
        return inputNames.flatMap { inputName -> FilterProperty? in
            let attribute = attributes[inputName] as! [String: Any]
            
            guard let minValue = attribute[kCIAttributeSliderMin] as? Float,
                let maxValue = attribute[kCIAttributeSliderMax] as? Float,
                let defaultValue = attribute[kCIAttributeDefault] as? Float else {
                    return nil
            }
            
            let name = inputName.substring(from: inputName.index(inputName.startIndex, offsetBy: 5))
            return FilterProperty(name: name, key: inputName, value: defaultValue, minimum: minValue, maximum: maxValue)
        }
    }
}

class FilteredImageView: GLKView, FilterPropertyDelegate {
    
    var filter: CIFilter? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    var inputImage: UIImage? {
        didSet {
            setNeedsDisplay()
        }
    }
    
    private var ciContext: CIContext!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open func commonInit() {
        clipsToBounds = true
        enableSetNeedsDisplay = true
        context = EAGLContext(api: .openGLES3)
        ciContext = CIContext(eaglContext: context)
    }
    
    override func draw(_ rect: CGRect) {
        if let inputImage = inputImage, let filter = filter, let inputCIImage = CIImage(image: inputImage) {
            filter.setValue(inputCIImage, forKey: kCIInputImageKey)
            
            if let outputImage = filter.outputImage {
                clearBackground()
                
                let inputBounds = inputCIImage.extent
                let drawableBounds = CGRect(x: 0, y: 0, width: self.drawableWidth, height: self.drawableHeight)
                let targetBounds = imageBoundsForContentMode(fromRect: inputBounds, toRect: drawableBounds)
                ciContext.draw(outputImage, in: targetBounds, from: inputBounds)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setNeedsDisplay()
    }
    
    private func clearBackground() {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        backgroundColor?.getRed(&r, green: &g, blue: &b, alpha: &a)
        glClearColor(GLfloat(r), GLfloat(g), GLfloat(b), GLfloat(a))
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
    }
    
    private func aspectFit(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        }
        
        return fitRect.integral
    }
    
    private func aspectFill(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.width = toRect.size.height  * fromAspectRatio
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        } else {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        }
        
        return fitRect.integral
    }
    
    private func imageBoundsForContentMode(fromRect: CGRect, toRect: CGRect) -> CGRect {
        switch contentMode {
        case .scaleAspectFill:
            return aspectFill(fromRect: fromRect, toRect: toRect)
        case .scaleAspectFit:
            return aspectFit(fromRect: fromRect, toRect: toRect)
        default:
            return fromRect
        }
    }
    
    func filterPropertyDidChange(_ property: FilterProperty) {
        if let filter = filter {
            filter.setValue(property.value, forKey: property.propertyKey)
            setNeedsDisplay()
        }
    }
}

class FiltersViewController: UIViewController {

    @IBOutlet weak var filteredImageView: FilteredImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var adjustView: UIView! {
        didSet {
            adjustView.isHidden = true
        }
    }
    
    fileprivate let filters: [Filter] = [
        Filter(name: "Chrome", filterName: "CIPhotoEffectChrome"),
        Filter(name: "Fade", filterName: "CIPhotoEffectFade"),
        Filter(name: "Instant", filterName: "CIPhotoEffectInstant"),
        Filter(name: "Mono", filterName: "CIPhotoEffectMono"),
        Filter(name: "Process", filterName: "CIPhotoEffectProcess"),
        Filter(name: "Sepia", filterName: "CISepiaTone"),
        Filter(name: "Vignette", filterName: "CIVignette"),
        Filter(name: "Photo Transfer", filterName: "CIPhotoEffectTransfer"),
        Filter(name: "Tonal", filterName: "CIPhotoEffectTonal"),
        Filter(name: "Invert", filterName: "CIColorInvert"),
        Filter(name: "Vibrance", filterName: "CIVibrance"),
    ]
    
    fileprivate var filterProperties: [FilterProperty] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    fileprivate var filterImage: UIImage? {
        didSet {
            filteredImages = Array(repeating: nil, count: filters.count)
            
            if let filterImage = filterImage, let image = CIImage(image: filterImage) {
                DispatchQueue.global(qos: .background).async {
                    self.filters.enumerated().forEach { (index, filter) in
                        filter.filter.setValue(image, forKey: kCIInputImageKey)
                        if let image = filter.filter.outputImage {
                            let finalImage = UIImage(ciImage: image)
                            self.filteredImages[index] = finalImage
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
        filterImage = ImageResizer(size: CGSize(width: 100, height: 100), fill: true).apply(for: #imageLiteral(resourceName: "Picture"))
    }
    
    @IBAction func didTapAdjustButton(_ sender: UIBarButtonItem) {
        adjustView.isHidden = !adjustView.isHidden
    }
}

class FilterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
}

class FilterPropertyTablesViewCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueSlider: UISlider!
    
    weak var delegate: FilterPropertyDelegate?
    
    var property: FilterProperty? {
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

public protocol Bla {
    func apply(for image: UIImage) -> UIImage?
}

public struct ImageResizer: Bla {
    
    public var size: CGSize
    public var fill: Bool
    
    public init(size: CGSize, fill: Bool) {
        self.size = size
        self.fill = fill
    }
    
    public func apply(for image: UIImage) -> UIImage? {
        let scale = UIScreen.main.scale
        let fromRect = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        let toRect = CGRect(x: 0, y: 0, width: size.width * scale, height: size.height * scale)
        
        let rect = fill ? aspectFill(fromRect: fromRect, toRect: toRect) : aspectFit(fromRect: fromRect, toRect: toRect)
        
        UIGraphicsBeginImageContextWithOptions(toRect.size, false, scale)
        image.draw(in: rect)
        
        let finalImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return finalImage
    }
    
    private func aspectFit(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        } else {
            fitRect.size.width = toRect.size.height  * fromAspectRatio
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        }
        
        return fitRect.integral
    }
    
    private func aspectFill(fromRect: CGRect, toRect: CGRect) -> CGRect {
        let fromAspectRatio = fromRect.size.width / fromRect.size.height
        let toAspectRatio = toRect.size.width / toRect.size.height
        
        var fitRect = toRect
        
        if (fromAspectRatio > toAspectRatio) {
            fitRect.size.width = toRect.size.height  * fromAspectRatio
            fitRect.origin.x += (toRect.size.width - fitRect.size.width) * 0.5
        } else {
            fitRect.size.height = toRect.size.width / fromAspectRatio
            fitRect.origin.y += (toRect.size.height - fitRect.size.height) * 0.5
        }
        
        return fitRect.integral
    }
}

extension FiltersViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filters.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "FilterCollectionViewCell",
                                                      for: indexPath) as! FilterCollectionViewCell
        
        if let filteredImage = filteredImages[indexPath.row] {
            cell.imageView.image = filteredImage
        } else {
            cell.imageView.image = nil
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let filter = filters[indexPath.row]
        filteredImageView.filter = filter.filter
        filterProperties = filter.properties
    }
}
