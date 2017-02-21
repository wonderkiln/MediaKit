//
//  MKFilteredVideoPlayer.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 20/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import AVFoundation

public enum ExportQuality {
    case low, medium, high
    
    var value: String {
        switch self {
        case .low    : return AVAssetExportPresetLowQuality
        case .medium : return AVAssetExportPresetMediumQuality
        case .high   : return AVAssetExportPresetHighestQuality
        }
    }
}

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
    
    public typealias ProgressBlock = (Double) -> Void
    public typealias CompletionBlock = () -> Void
    
    private var progressBlock: ProgressBlock?
    private var progressTimer: Timer?
    
    @objc private func progressTimerDidTick(_ timer: Timer) {
        guard let session = timer.userInfo as? AVAssetExportSession else {
            return
        }
        progressBlock?(Double(session.progress))
    }
    
    public func export(to url: URL, quality: ExportQuality = .high, progress: ProgressBlock? = nil, completion: @escaping CompletionBlock) {
        guard let asset = asset else {
            return
        }
        
        guard let session = AVAssetExportSession(asset: asset, presetName: quality.value) else {
            return
        }
        
        session.videoComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: processFrame)
        session.outputFileType = AVFileTypeMPEG4
        session.outputURL = url
        
        if let progress = progress {
            progressBlock = progress
            progressTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(progressTimerDidTick(_:)), userInfo: session, repeats: true)
        }
        
        session.exportAsynchronously {
            switch session.status {
            case .cancelled, .completed, .failed:
                self.progressTimer?.invalidate()
                self.progressTimer = nil
                self.progressBlock = nil
            default:
                break
            }
            if session.status == .completed {
                DispatchQueue.main.async {
                    completion()
                }
            }
        }
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
