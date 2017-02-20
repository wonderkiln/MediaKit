//
//  MKFilteredVideoPlayer.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 20/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import MobileCoreServices
import AVFoundation

public class MKFilteredVideoPlayer: UIView {
    
    public var asset: AVAsset? {
        didSet {
            setup()
        }
    }
    
    public var filter: CIFilter?
    public var player: AVPlayer?
    
    public var loop: Bool = false {
        didSet {
            if loop {
                player?.actionAtItemEnd = .none
                NotificationCenter.default.addObserver(self, selector: #selector(playerItemDidPlayToEndTime), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: nil)
            } else {
                NotificationCenter.default.removeObserver(self)
            }
        }
    }
    
    private var playerLayer: AVPlayerLayer?
    
    public func play(loop: Bool) {
        self.loop = loop
        player?.play()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setup() {
        layer.sublayers?.forEach {
            if $0 is AVPlayerLayer {
                $0.removeFromSuperlayer()
            }
        }
        
        guard let asset = asset else {
            return
        }
        
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: processFrame)
        
        let player = AVPlayer(playerItem: item)
        
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = bounds
        layer.addSublayer(playerLayer)
        
        self.player = player
        self.playerLayer = playerLayer
    }
    
    private func processFrame(_ request: AVAsynchronousCIImageFilteringRequest) {
        guard let filter = filter else {
            request.finish(with: request.sourceImage, context: nil)
            return
        }
        
        let source = request.sourceImage.clampingToExtent()
        filter.setValue(source, forKey: kCIInputImageKey)
        let output = filter.outputImage!.cropping(to: request.sourceImage.extent)
        request.finish(with: output, context: nil)
    }
    
    @objc private func playerItemDidPlayToEndTime() {
        player?.seek(to: CMTime.init(seconds: 0, preferredTimescale: 1000))
        player?.play()
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
