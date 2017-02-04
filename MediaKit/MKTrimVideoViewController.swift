//
//  MKTrimVideoViewController.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 13/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import MARKRangeSlider

public class MKTrimVideoViewController: UIViewController, MKVideoExportController {

    @IBOutlet public weak var containerView: UIView!
    @IBOutlet public weak var bottomView: UIView!
    @IBOutlet public weak var rangeSlider: MARKRangeSlider!
    
    public var originalURL: URL? {
        didSet {
            if let url = originalURL {
                let player = AVPlayer(url: url)
                playerController?.player = player
            }
        }
    }
    
    public func export(_ callback: @escaping (URL) -> Void) {
        guard let url = originalURL else {
            return
        }
        guard min >= 0, max >= 0, max - min > 3, max - min < 15 else {
            return
        }
        
        let trim = MKTrimVideo(startTime: Double(min), endTime: Double(max))
        trim.apply(to: MKVideoType(url)) { (output, error) in
            if let error = error {
                print(error)
                return
            }
            callback(output.url)
        }
    }
    
    public init(url: URL) {
        self.originalURL = url
        super.init(nibName: "MKTrimVideoViewController",
                   bundle: Bundle(for: MKTrimVideoViewController.self))
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var playerController: AVPlayerViewController?
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let url = originalURL else {
            return
        }
        
        let player = AVPlayer(url: url)
        let playerController = AVPlayerViewController()
        playerController.player = player
        playerController.showsPlaybackControls = false
        containerView.addSubview(playerController.view)
        addChildViewController(playerController)
        playerController.didMove(toParentViewController: self)
        
        rangeSlider.setMinValue(0.0, maxValue: CGFloat(player.currentItem?.asset.duration.seconds ?? 0.0))
        rangeSlider.setLeftValue(rangeSlider.minimumValue, rightValue: rangeSlider.maximumValue)
        
        self.playerController = playerController
    }
    
    var min: CGFloat = -1, max: CGFloat = -1
    
    @IBAction func rangeSliderValueChanged(_ rangeSlider: MARKRangeSlider) {
        let time = min != rangeSlider.leftValue ?
            CMTime(seconds: Double(rangeSlider.leftValue), preferredTimescale: 1000) :
            CMTime(seconds: Double(rangeSlider.rightValue), preferredTimescale: 1000)
        
        playerController?.player?.seek(to: time,
                                       toleranceBefore: kCMTimeZero,
                                       toleranceAfter: kCMTimeZero)
        
        min = rangeSlider.leftValue
        max = rangeSlider.rightValue
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerController?.view.frame = containerView.bounds
    }
}
