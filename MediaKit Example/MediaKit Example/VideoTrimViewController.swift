//
//  VideoTrimViewController.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 21/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import AVFoundation

class VideoTrimViewController: UIViewController {

    private var asset: AVAsset?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let url = Bundle.main.url(forResource: "Video", withExtension: "mp4") {
            let asset = AVAsset(url: url)
            
            let playerItem = AVPlayerItem(asset: asset)
            let player = AVPlayer(playerItem: playerItem)
            let playerLayer = AVPlayerLayer(player: player)
            playerLayer.frame = view.bounds
            view.layer.addSublayer(playerLayer)
            player.isMuted = true
            player.play()
            
            self.asset = asset
        }
    }

    @IBAction func didTapExportButton(_ button: UIBarButtonItem) {
        guard let asset = asset else {
            return
        }
        
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("temp.mp4")
        try? FileManager.default.removeItem(at: url)
        
        MKVideoUtils.trim(asset: asset, to: url, quality: .medium, start: 0.0, end: 5.0, progress: { progress in
            print("Exporting... \(Int(progress * 100))%")
        }, completion: {
            print("Done: \(url)")
        })
    }
}
