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
            updateTimeObserver()
            setup()
        }
    }
    
    private var timeObserverToken: Any?
    
    public var startTime: Double? {
        didSet {
            if oldValue != startTime {
                if let startTime = startTime {
                    let time = CMTime(seconds: startTime, preferredTimescale: 1000)
                    self.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
                }
            }
        }
    }
    public var endTime: Double? {
        didSet {
            if oldValue != endTime {
                if let endTime = endTime {
                    let time = CMTime(seconds: endTime, preferredTimescale: 1000)
                    self.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
                }
                updateTimeObserver()
            }
        }
    }
    
    private func updateTimeObserver() {
        if let token = timeObserverToken {
            player?.removeTimeObserver(token)
            timeObserverToken = nil
        }
        if let endTime = endTime ?? asset?.duration.seconds {
            let time = CMTime(seconds: endTime, preferredTimescale: 1000)
            timeObserverToken = player?.addBoundaryTimeObserver(forTimes: [NSValue(time: time)], queue: .main, using: {
                if self.loop {
                    let startTime = self.startTime ?? 0.0
                    let time = CMTime(seconds: startTime, preferredTimescale: 1000)
                    self.player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
                    self.player?.play()
                } else {
                    self.player?.pause()
                }
            })
        }
    }
    
    public var filter: CIFilter?
    public var player: AVPlayer?
    
    public var loop: Bool = false {
        didSet {
            if oldValue != loop {
                updateTimeObserver()
            }
        }
    }
    
    private var playerLayer: AVPlayerLayer?
    
    public func play(loop: Bool) {
        self.loop = loop
        let time = CMTime.init(seconds: startTime ?? 0, preferredTimescale: 1000)
        player?.seek(to: time, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        player?.play()
    }
    
    public func pause() {
        player?.pause()
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
        
        if let start = startTime, let end = endTime {
            let start = CMTime(seconds: start, preferredTimescale: 1000)
            let end = CMTime(seconds: end, preferredTimescale: 1000)
            session.timeRange = CMTimeRange(start: start, end: end)
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
        guard let asset = asset else {
            return
        }
        
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = AVVideoComposition(asset: asset, applyingCIFiltersWithHandler: processFrame)
        
        if self.player == nil {
            let player = AVPlayer(playerItem: item)
            
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = bounds
            layer.addSublayer(playerLayer)
            
            self.player = player
            self.playerLayer = playerLayer
        } else {
            self.player?.replaceCurrentItem(with: item)
        }
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
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
}
