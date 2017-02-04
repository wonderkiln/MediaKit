//
//  MKGridView.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 11/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit

public protocol MKGridViewDelegate: class {
    func gridView(_ view: MKGridView, didChangeFrameTo newFrame: CGRect)
}

public class MKGridView: UIView {
    
    public weak var delegate: MKGridViewDelegate?
    
    public var minimumSize: CGFloat = 50.0
    
    public var gridColor: UIColor = UIColor.white.withAlphaComponent(0.5) {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var gridLineWidth: CGFloat = 1.0 {
        didSet {
            setNeedsDisplay()
        }
    }
    
    public var thumbSize: CGFloat = 20.0 {
        didSet {
            layoutIfNeeded()
        }
    }
    
    public var ratio: CGFloat? {
        didSet {
            if let ratio = ratio {
                frame.size.width = ratio * frame.size.height
            }
        }
    }
    
    fileprivate var view1: UIView!
    fileprivate var view2: UIView!
    fileprivate var view3: UIView!
    fileprivate var view4: UIView!
    
    fileprivate enum GripType: Int {
        case topLeft     = 1
        case topRight    = 2
        case bottomLeft  = 3
        case bottomRight = 4
        case none        = 0
    }
    
    fileprivate var grip: GripType = .none
    fileprivate var startFrame: CGRect = CGRect.zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    open func commonInit() {
        let long = UILongPressGestureRecognizer(target: self, action: #selector(didLongPress(_:)))
        long.minimumPressDuration = 0.1
        self.addGestureRecognizer(long)
        
        view1 = UIView()
        view1.backgroundColor = UIColor.white
        
        view2 = UIView()
        view2.backgroundColor = UIColor.white
        
        view3 = UIView()
        view3.backgroundColor = UIColor.white
        
        view4 = UIView()
        view4.backgroundColor = UIColor.white
        
        addSubview(view1)
        addSubview(view2)
        addSubview(view3)
        addSubview(view4)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        
        view1.frame = CGRect(x: -thumbSize / 2.0, y: -thumbSize / 2.0, width: thumbSize, height: thumbSize)
        view2.frame = CGRect(x: frame.width - thumbSize / 2.0, y: -thumbSize / 2.0, width: thumbSize, height: thumbSize)
        view3.frame = CGRect(x: -thumbSize / 2.0, y: frame.height - thumbSize / 2.0, width: thumbSize, height: thumbSize)
        view4.frame = CGRect(x: frame.width - thumbSize / 2.0, y: frame.height - thumbSize / 2.0, width: thumbSize, height: thumbSize)
        
        view1.layer.cornerRadius = thumbSize / 2.0
        view2.layer.cornerRadius = thumbSize / 2.0
        view3.layer.cornerRadius = thumbSize / 2.0
        view4.layer.cornerRadius = thumbSize / 2.0
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return
            view1.frame.contains(point) ||
                view2.frame.contains(point) ||
                view3.frame.contains(point) ||
                view4.frame.contains(point)
    }
    
    @objc fileprivate func didLongPress(_ recognizer: UILongPressGestureRecognizer) {
        guard let superview = superview else {
            return
        }
        
        switch recognizer.state {
        case .began:
            startFrame = frame
            let touchLocation = recognizer.location(in: self)
            
            if view1.frame.contains(touchLocation) {
                grip = .topLeft
            } else if view2.frame.contains(touchLocation) {
                grip = .topRight
            } else if view3.frame.contains(touchLocation) {
                grip = .bottomLeft
            } else if view4.frame.contains(touchLocation) {
                grip = .bottomRight
            } else {
                grip = .none
            }
            
            subviews.forEach {
                $0.isHidden = true
            }
            
        case .changed:
            let touchLocation = recognizer.location(in: superview)
            var initialFrame = frame
            
            switch grip {
            case .topLeft:
                initialFrame.size.width = max(startFrame.minX - touchLocation.x + startFrame.width, minimumSize)
                initialFrame.size.height = max(startFrame.minY - touchLocation.y + startFrame.height, minimumSize)
                
                if let ratio = ratio {
                    initialFrame.size.width = ratio * initialFrame.size.height
                }
                
                initialFrame.origin.x = -(initialFrame.size.width - startFrame.minX - startFrame.width)
                initialFrame.origin.y = -(initialFrame.size.height - startFrame.minY - startFrame.height)
                
            case .topRight:
                initialFrame.size.width = max(touchLocation.x - startFrame.minX, minimumSize)
                initialFrame.size.height = max(startFrame.minY - touchLocation.y + startFrame.height, minimumSize)
                
                if let ratio = ratio {
                    initialFrame.size.width = ratio * initialFrame.size.height
                }
                
                initialFrame.origin.y = -(initialFrame.size.height - startFrame.minY - startFrame.height)
                
            case .bottomLeft:
                initialFrame.size.width = max(startFrame.minX - touchLocation.x + startFrame.width, minimumSize)
                initialFrame.size.height = max(touchLocation.y - startFrame.minY, minimumSize)
                
                if let ratio = ratio {
                    initialFrame.size.width = ratio * initialFrame.size.height
                }
                
                initialFrame.origin.x = -(initialFrame.size.width - startFrame.minX - startFrame.width)
                
            case .bottomRight:
                initialFrame.size.width = max(touchLocation.x - startFrame.minX, minimumSize)
                initialFrame.size.height = max(touchLocation.y - startFrame.minY, minimumSize)
                
                if let ratio = ratio {
                    initialFrame.size.width = ratio * initialFrame.size.height
                }
                
            default:
                break
            }
            
            frame = initialFrame
            delegate?.gridView(self, didChangeFrameTo: initialFrame)
            setNeedsDisplay()
            
        default:
            grip = .none
            
            subviews.forEach {
                $0.isHidden = false
            }
        }
    }
    
    public override func draw(_ rect: CGRect) {
        guard let context = UIGraphicsGetCurrentContext() else { return }
        
        context.addRect(CGRect(x: 0.0 * rect.width / 3.0, y: 0, width: gridLineWidth, height: rect.height))
        context.addRect(CGRect(x: 1.0 * rect.width / 3.0 - gridLineWidth / 2.0, y: 0, width: gridLineWidth, height: rect.height))
        context.addRect(CGRect(x: 2.0 * rect.width / 3.0 - gridLineWidth / 2.0, y: 0, width: gridLineWidth, height: rect.height))
        context.addRect(CGRect(x: 3.0 * rect.width / 3.0 - gridLineWidth, y: 0, width: gridLineWidth, height: rect.height))
        
        context.addRect(CGRect(x: 0, y: 0.0 * rect.height / 3.0, width: rect.width, height: gridLineWidth))
        context.addRect(CGRect(x: 0, y: 1.0 * rect.height / 3.0 - gridLineWidth / 2.0, width: rect.width, height: gridLineWidth))
        context.addRect(CGRect(x: 0, y: 2.0 * rect.height / 3.0 - gridLineWidth / 2.0, width: rect.width, height: gridLineWidth))
        context.addRect(CGRect(x: 0, y: 3.0 * rect.height / 3.0 - gridLineWidth, width: rect.width, height: gridLineWidth))
        
        context.setFillColor(gridColor.cgColor)
        context.fillPath()
    }
}
