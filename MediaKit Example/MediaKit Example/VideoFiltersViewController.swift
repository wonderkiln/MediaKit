//
//  VideoFiltersViewController.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 18/02/2017.
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

class VideoFiltersViewController: UIViewController {
    
    @IBOutlet weak var videoPlayer: MKFilteredVideoPlayer!
    
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
    
    fileprivate var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.mediaTypes = [kUTTypeMovie as String]
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }
    
    @IBAction func didTap() {
        videoPlayer.filter = filters[index].filter
        index = (index + 1) % filters.count
    }
}

extension VideoFiltersViewController: UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        
        guard let url = info[UIImagePickerControllerReferenceURL] as? URL else {
            return
        }
        
        videoPlayer.asset = AVAsset(url: url)
        videoPlayer.player?.isMuted = true
        videoPlayer.play(loop: true)
    }
}
