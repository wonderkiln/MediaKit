//
//  MKCropRectView.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 12/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

protocol MKCropRectViewDelegate: class {
    func cropRectViewDidBeginEditing(_ view: MKCropRectView)
    func cropRectViewDidChange(_ view: MKCropRectView)
    func cropRectViewDidEndEditing(_ view: MKCropRectView)
}

class MKCropRectView: UIView, MKResizeControlDelegate {
    weak var delegate: MKCropRectViewDelegate?
    var showsGridMajor = true {
        didSet {
            setNeedsDisplay()
        }
    }
    var showsGridMinor = false {
        didSet {
            setNeedsDisplay()
        }
    }
    var keepAspectRatio = false {
        didSet {
            if keepAspectRatio {
                let width = bounds.width
                let height = bounds.height
                fixedAspectRatio = min(width / height, height / width)
            }
        }
    }
    
    fileprivate var resizeImageView: UIImageView!
    fileprivate let topLeftCornerView = MKResizeControl()
    fileprivate let topRightCornerView = MKResizeControl()
    fileprivate let bottomLeftCornerView = MKResizeControl()
    fileprivate let bottomRightCornerView = MKResizeControl()
    fileprivate let topEdgeView = MKResizeControl()
    fileprivate let leftEdgeView = MKResizeControl()
    fileprivate let rightEdgeView = MKResizeControl()
    fileprivate let bottomEdgeView = MKResizeControl()
    fileprivate var initialRect = CGRect.zero
    fileprivate var fixedAspectRatio: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        backgroundColor = UIColor.clear
        contentMode = .redraw
        
        resizeImageView = UIImageView(frame: bounds.insetBy(dx: 0.0, dy: 0.0))
        resizeImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        let bundle = Bundle(for: type(of: self))
        resizeImageView.image = UIImage(named: "PhotoCropEditorBorder", in: bundle, compatibleWith: nil)
        addSubview(resizeImageView)
        
        topEdgeView.delegate = self
        addSubview(topEdgeView)
        leftEdgeView.delegate = self
        addSubview(leftEdgeView)
        rightEdgeView.delegate = self
        addSubview(rightEdgeView)
        bottomEdgeView.delegate = self
        addSubview(bottomEdgeView)
        
        topLeftCornerView.delegate = self
        addSubview(topLeftCornerView)
        topRightCornerView.delegate = self
        addSubview(topRightCornerView)
        bottomLeftCornerView.delegate = self
        addSubview(bottomLeftCornerView)
        bottomRightCornerView.delegate = self
        addSubview(bottomRightCornerView)
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        for subview in subviews where subview is MKResizeControl {
            if subview.frame.contains(point) {
                return subview
            }
        }
        return nil
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        let width = bounds.width
        let height = bounds.height
        
        for i in 0 ..< 3 {
            let borderPadding: CGFloat = 0.5
            
            if showsGridMinor {
                for j in 1 ..< 3 {
                    UIColor(red: 1.0, green: 1.0, blue: 0.0, alpha: 0.3).set()
                    UIRectFill(CGRect(x: round((width / 9.0) * CGFloat(j) + (width / 3.0) * CGFloat(i)), y: borderPadding, width: 1.0, height: round(height) - borderPadding * 2.0))
                    UIRectFill(CGRect(x: borderPadding, y: round((height / 9.0) * CGFloat(j) + (height / 3.0) * CGFloat(i)), width: round(width) - borderPadding * 2.0, height: 1.0))
                }
            }
            
            if showsGridMajor {
                if i > 0 {
                    UIColor.white.withAlphaComponent(0.5).set()
                    UIRectFill(CGRect(x: round(CGFloat(i) * width / 3.0), y: borderPadding, width: 1.0, height: round(height) - borderPadding * 2.0))
                    UIRectFill(CGRect(x: borderPadding, y: round(CGFloat(i) * height / 3.0), width: round(width) - borderPadding * 2.0, height: 1.0))
                }
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        topLeftCornerView.frame.origin = CGPoint(x: topLeftCornerView.bounds.width / -2.0, y: topLeftCornerView.bounds.height / -2.0)
        topRightCornerView.frame.origin = CGPoint(x: bounds.width - topRightCornerView.bounds.width - 2.0, y: topRightCornerView.bounds.height / -2.0)
        bottomLeftCornerView.frame.origin = CGPoint(x: bottomLeftCornerView.bounds.width / -2.0, y: bounds.height - bottomLeftCornerView.bounds.height / 2.0)
        bottomRightCornerView.frame.origin = CGPoint(x: bounds.width - bottomRightCornerView.bounds.width / 2.0, y: bounds.height - bottomRightCornerView.bounds.height / 2.0)
        
        topEdgeView.frame = CGRect(x: topLeftCornerView.frame.maxX, y: topEdgeView.frame.height / -2.0, width: topRightCornerView.frame.minX - topLeftCornerView.frame.maxX, height: topEdgeView.bounds.height)
        leftEdgeView.frame = CGRect(x: leftEdgeView.frame.width / -2.0, y: topLeftCornerView.frame.maxY, width: leftEdgeView.frame.width, height: bottomLeftCornerView.frame.minY - topLeftCornerView.frame.maxY)
        bottomEdgeView.frame = CGRect(x: bottomLeftCornerView.frame.maxX, y: bottomLeftCornerView.frame.minY, width: bottomRightCornerView.frame.minX - bottomLeftCornerView.frame.maxX, height: bottomEdgeView.frame.height)
        rightEdgeView.frame = CGRect(x: bounds.width - rightEdgeView.frame.width / 2.0, y: topRightCornerView.frame.maxY, width: rightEdgeView.frame.width, height: bottomRightCornerView.frame.minY - topRightCornerView.frame.maxY)
    }
    
    func enableResizing(_ enabled: Bool) {
        resizeImageView.isHidden = !enabled
        
        topLeftCornerView.enabled = enabled
        topRightCornerView.enabled = enabled
        bottomLeftCornerView.enabled = enabled
        bottomRightCornerView.enabled = enabled
        
        topEdgeView.enabled = enabled
        leftEdgeView.enabled = enabled
        bottomEdgeView.enabled = enabled
        rightEdgeView.enabled = enabled
    }

    // MARK: - MKResizeControl delegate methods
    func resizeControlDidBeginResizing(_ control: MKResizeControl) {
        initialRect = frame
        delegate?.cropRectViewDidBeginEditing(self)
    }
    
    func resizeControlDidResize(_ control: MKResizeControl) {
        frame = cropRectWithMKResizeControlView(control)
        delegate?.cropRectViewDidChange(self)
    }
    
    func resizeControlDidEndResizing(_ control: MKResizeControl) {
        delegate?.cropRectViewDidEndEditing(self)
    }
    
    fileprivate func cropRectWithMKResizeControlView(_ resizeControl: MKResizeControl) -> CGRect {
        var rect = frame
        
        if resizeControl == topEdgeView {
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY + resizeControl.translation.y,
                          width: initialRect.width,
                          height: initialRect.height - resizeControl.translation.y)
            
            if keepAspectRatio {
                rect = constrainedRectWithRectBasisOfHeight(rect)
            }
        } else if resizeControl == leftEdgeView {
            rect = CGRect(x: initialRect.minX + resizeControl.translation.x,
                          y: initialRect.minY,
                          width: initialRect.width - resizeControl.translation.x,
                          height: initialRect.height)
            
            if keepAspectRatio {
                rect = constrainedRectWithRectBasisOfWidth(rect)
            }
        } else if resizeControl == bottomEdgeView {
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY,
                          width: initialRect.width,
                          height: initialRect.height + resizeControl.translation.y)
            
            if keepAspectRatio {
                rect = constrainedRectWithRectBasisOfHeight(rect)
            }
        } else if resizeControl == rightEdgeView {
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY,
                          width: initialRect.width + resizeControl.translation.x,
                          height: initialRect.height)
            
            if keepAspectRatio {
                rect = constrainedRectWithRectBasisOfWidth(rect)
            }
        } else if resizeControl == topLeftCornerView {
            rect = CGRect(x: initialRect.minX + resizeControl.translation.x,
                          y: initialRect.minY + resizeControl.translation.y,
                          width: initialRect.width - resizeControl.translation.x,
                          height: initialRect.height - resizeControl.translation.y)
            
            if keepAspectRatio {
                var constrainedFrame: CGRect
                if abs(resizeControl.translation.x) < abs(resizeControl.translation.y) {
                    constrainedFrame = constrainedRectWithRectBasisOfHeight(rect)
                } else {
                    constrainedFrame = constrainedRectWithRectBasisOfWidth(rect)
                }
                constrainedFrame.origin.x -= constrainedFrame.width - rect.width
                constrainedFrame.origin.y -= constrainedFrame.height - rect.height
                rect = constrainedFrame
            }
        } else if resizeControl == topRightCornerView {
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY + resizeControl.translation.y,
                          width: initialRect.width + resizeControl.translation.x,
                          height: initialRect.height - resizeControl.translation.y)
            
            if keepAspectRatio {
                if abs(resizeControl.translation.x) < abs(resizeControl.translation.y) {
                    rect = constrainedRectWithRectBasisOfHeight(rect)
                } else {
                    rect = constrainedRectWithRectBasisOfWidth(rect)
                }
            }
        } else if resizeControl == bottomLeftCornerView {
            rect = CGRect(x: initialRect.minX + resizeControl.translation.x,
                          y: initialRect.minY,
                          width: initialRect.width - resizeControl.translation.x,
                          height: initialRect.height + resizeControl.translation.y)
            
            if keepAspectRatio {
                var constrainedFrame: CGRect
                if abs(resizeControl.translation.x) < abs(resizeControl.translation.y) {
                    constrainedFrame = constrainedRectWithRectBasisOfHeight(rect)
                } else {
                    constrainedFrame = constrainedRectWithRectBasisOfWidth(rect)
                }
                constrainedFrame.origin.x -= constrainedFrame.width - rect.width
                rect = constrainedFrame
            }
        } else if resizeControl == bottomRightCornerView {
            rect = CGRect(x: initialRect.minX,
                          y: initialRect.minY,
                          width: initialRect.width + resizeControl.translation.x,
                          height: initialRect.height + resizeControl.translation.y)
            
            if keepAspectRatio {
                if abs(resizeControl.translation.x) < abs(resizeControl.translation.y) {
                    rect = constrainedRectWithRectBasisOfHeight(rect)
                } else {
                    rect = constrainedRectWithRectBasisOfWidth(rect)
                }
            }
        }
        
        let minWidth = leftEdgeView.bounds.width + rightEdgeView.bounds.width
        if rect.width < minWidth {
            rect.origin.x = frame.maxX - minWidth
            rect.size.width = minWidth
        }
        
        let minHeight = topEdgeView.bounds.height + bottomEdgeView.bounds.height
        if rect.height < minHeight {
            rect.origin.y = frame.maxY - minHeight
            rect.size.height = minHeight
        }
        
        if fixedAspectRatio > 0 {
            var constraintedFrame = rect
            if rect.width < minWidth {
                constraintedFrame.size.width = rect.size.height * (minWidth / rect.size.width)
            }
            if rect.height < minHeight {
                constraintedFrame.size.height = rect.size.width * (minHeight / rect.size.height)
            }
            rect = constraintedFrame
        }
        
        return rect
    }
    
    fileprivate func constrainedRectWithRectBasisOfWidth(_ frame: CGRect) -> CGRect {
        var result = frame
        let width = frame.width
        var height = frame.height
        
        if width < height {
           height = width / fixedAspectRatio
        } else {
            height = width * fixedAspectRatio
        }
        result.size = CGSize(width: width, height: height)
        return result
    }
    
    fileprivate func constrainedRectWithRectBasisOfHeight(_ frame: CGRect) -> CGRect {
        var result = frame
        var width = frame.width
        let height = frame.height
        
        if width < height {
            width = height * fixedAspectRatio
        } else {
            width = height / fixedAspectRatio
        }
        result.size = CGSize(width: width, height: height)
        return result
    }
}
