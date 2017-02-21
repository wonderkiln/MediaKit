//
//  MKVideoUtils.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 21/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import AVFoundation

public class MKVideoUtils {
    
    public typealias ProgressBlock = (Double) -> Void
    public typealias CompletionBlock = () -> Void
    
    public static func trim(asset: AVAsset, to url: URL, quality: ExportQuality = .high, start: Double, end: Double, progress: ProgressBlock? = nil, completion: @escaping CompletionBlock) {
        guard let session = AVAssetExportSession(asset: asset, presetName: quality.value) else {
            return
        }
        
        let start = CMTime(seconds: start, preferredTimescale: 1000)
        let end = CMTime(seconds: end, preferredTimescale: 1000)
        let range = CMTimeRange(start: start, end: end)
        
        session.outputFileType = AVFileTypeMPEG4
        session.timeRange = range
        session.outputURL = url
        
        session.exportAsynchronously {
            DispatchQueue.main.async {
                switch session.status {
                case .completed:
                    completion()
                case .exporting:
                    progress?(Double(session.progress))
                default:
                    break
                }
            }
        }
    }
}
