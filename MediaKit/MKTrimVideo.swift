//
//  MKTrimVideo.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 13/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import AVFoundation

public class MKTrimVideo: MKProtocol {
    
    public var displayName: String = "Trim"
    
    public var startTime: Double
    public var endTime: Double
    
    public var outputURL: URL?
    
    public init(startTime: Double, endTime: Double) {
        self.startTime = startTime
        self.endTime = endTime
    }
    
    private func defaultOutputURL() -> URL? {
        guard let documentDirectory = try? FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true) else {
                return nil
        }
        
        return documentDirectory.appendingPathComponent("output.mp4")
    }
    
    public func apply<InputType : MKInputType>(to input: InputType, _ completion: @escaping (InputType, Error?) -> Void) {
        guard let media = input as? MKVideoType else {
            return completion(input, MKError("`MKTrimVideo` only works with `MKVideoType` types"))
        }
        
        let asset = AVAsset(url: media.url)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {
            return completion(input, MKError("`MKTrimVideo` could not create `AVAssetExportSession`"))
        }
        
        guard let outputURL = self.outputURL ?? defaultOutputURL() else {
            return completion(input, MKError("`MKTrimVideo` could not create output URL"))
        }
        
        try? FileManager.default.removeItem(at: outputURL)
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileTypeMPEG4
        
        let start = CMTime(seconds: startTime, preferredTimescale: 1000)
        let end = CMTime(seconds: endTime, preferredTimescale: 1000)
        let range = CMTimeRange(start: start, end: end)
        
        exportSession.timeRange = range
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                switch exportSession.status {
                case .completed:
                    print("`MKTrimVideo` was completed: \(outputURL)")
                    completion(MKVideoType(outputURL) as! InputType, nil)
                case .exporting:
                    print("`MKTrimVideo` is exporting: \(exportSession.progress)")
                default:
                    print("`MKTrimVideo` export failed: \(outputURL) \(exportSession.error)")
                    completion(input, MKError("`MKTrimVideo` export failed: \(exportSession.error)"))
                    break
                }
            }
        }
    }
}
