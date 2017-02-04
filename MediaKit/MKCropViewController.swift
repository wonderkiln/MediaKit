//
//  MKCropViewController.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 09/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public class MKCropViewController: UIViewController, MKImageExportController {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var maskView: MKMaskView!
    @IBOutlet weak var gridView: MKGridView! {
        didSet {
            gridView.delegate = self
        }
    }
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var topLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var leadingLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var trailingLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var topPaddingLayoutConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomPaddingLayoutConstraint: NSLayoutConstraint!
    
    public var originalImage: UIImage? {
        didSet {
            imageView.image = originalImage
        }
    }
    
    public var afterEffects: [MKProtocol] = [
        MKResizeImage(toSize: CGSize(width: 1080, height: 1920), fillImage: true)
    ]
    
    public func export(_ callback: @escaping (UIImage) -> Void) {
        guard let originalImage = originalImage else {
            return
        }
        
        var effects: [MKProtocol] = [MKCropImage(relativeRect: relativeCropRectangle())]
        effects.append(contentsOf: afterEffects)
        
        MKMultipleEffects(effects).apply(to: MKImageType(originalImage)) { (output, _) in
            callback(output.image)
        }
    }
    
    public init() {
        super.init(nibName: "MKCropViewController", bundle: Bundle(for: MKCropViewController.self))
    }
    
    public init(image: UIImage) {
        self.originalImage = image
        super.init(nibName: "MKCropViewController", bundle: Bundle(for: MKCropViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        if let originalImage = originalImage {
            imageView.image = originalImage
            view.layoutIfNeeded()
        }
    }
    
    fileprivate func updateMinZoomScaleForSize(_ size: CGSize) {
        let widthScale = size.width / imageView.bounds.width
        let heightScale = size.height / imageView.bounds.height
        let minScale = min(widthScale, heightScale) / 1.2
        
        scrollView.minimumZoomScale = minScale
        scrollView.zoomScale = minScale
    }
    
    fileprivate func updateConstraintsForSize(_ size: CGSize) {
        let yOffset = max(0, (size.height - imageView.frame.height) / 2)
        topLayoutConstraint.constant = yOffset
        bottomLayoutConstraint.constant = yOffset
        
        let xOffset = max(0, (size.width - imageView.frame.width) / 2)
        leadingLayoutConstraint.constant = xOffset
        trailingLayoutConstraint.constant = xOffset
        
        view.layoutIfNeeded()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateMinZoomScaleForSize(view.bounds.size)
        
        let maskSize = CGSize(width: view.frame.width / 3.0, height: view.frame.width / 3.0)
        let maskFrame = CGRect(x: (view.frame.width - maskSize.width) / 2.0,
                               y: (view.frame.height - maskSize.height) / 2.0,
                               width: maskSize.width,
                               height: maskSize.height)
        
        maskView.maskFrame = maskFrame
        gridView.frame = maskFrame
    }
}

extension MKCropViewController: UIScrollViewDelegate {
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateConstraintsForSize(view.bounds.size)
    }
}

extension MKCropViewController: MKGridViewDelegate {
    
    public func relativeCropRectangle() -> CGRect {
        let imageViewFrame = imageView.frame
            .offsetBy(dx: -scrollView.contentOffset.x, dy: -scrollView.contentOffset.y)
        
        let gridViewFrame = imageViewFrame.intersection(gridView.frame)
            .offsetBy(dx: scrollView.contentOffset.x, dy: scrollView.contentOffset.y)
        
        
        return CGRect(x: (gridViewFrame.origin.x - imageView.frame.origin.x) / imageView.frame.width,
                      y: (gridViewFrame.origin.y - imageView.frame.origin.y) / imageView.frame.height,
                      width: gridViewFrame.width / imageView.frame.width,
                      height: gridViewFrame.height / imageView.frame.height)
    }
    
    public func gridView(_ view: MKGridView, didChangeFrameTo newFrame: CGRect) {
        maskView.maskFrame = newFrame
    }
}
