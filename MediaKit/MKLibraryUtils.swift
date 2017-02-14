//
//  MKLibraryUtils.swift
//  MediaKit Example
//
//  Created by Adrian Mateoaea on 14/02/2017.
//  Copyright © 2017 Flurgle. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary

public class MKLibraryAsset {
    
    public enum `Type` {
        case unknown
        case image
        case video
    }
    
    public var type: Type = .unknown
    public var duration: TimeInterval?
    public var phAsset: PHAsset!
}

public enum MKLibraryType {
    case all
    case images
    case videos
}

public enum MKLibraryResult<T> {
    case success(T)
    case fail(String)
}

public class MKLibraryUtils {
    
    public static func image(for asset: PHAsset, with size: CGSize, completion: @escaping (UIImage?) -> Void) {
        let scale = UIScreen.main.scale
        let size = CGSize(width: size.width * scale, height: size.height * scale)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, _) in
            DispatchQueue.main.async {
                completion(image)
            }
        })
    }
    
    public static func video(for asset: PHAsset, completion: @escaping (AVAsset?) -> Void) {
        let options = PHVideoRequestOptions()
        options.version = .current
        options.deliveryMode = .automatic
        
        options.progressHandler = { (progress, _, _, _) in
            print("Getting video progress: \(progress)")
        }
        
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset, _, _) in
            DispatchQueue.main.async {
                completion(asset)
            }
        }
    }
    
    public static func thumbnail(for asset: PHAsset, with size: CGSize = CGSize(width: 100, height: 100), completion: @escaping (UIImage?) -> Void) {
        let scale = UIScreen.main.scale
        let size = CGSize(width: size.width * scale, height: size.height * scale)
        
        let options = PHImageRequestOptions()
        options.isSynchronous = false
        options.deliveryMode = .fastFormat
        options.resizeMode = .fast
        
        PHImageManager.default().requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options, resultHandler: { (image, _) in
            DispatchQueue.main.async {
                completion(image)
            }
        })
    }
    
    public static func authorize(_ completion: @escaping (Bool) -> ()) {
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .authorized:
            completion(true)
        case .denied, .restricted :
            completion(false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization() { status in
                completion(status == .authorized)
            }
        }
    }
    
    public static func fetch(type: MKLibraryType, limit: Int? = nil, completion: @escaping (MKLibraryResult<[MKLibraryAsset]>) -> ()) {
        authorize { authorized in
            if !authorized {
                completion(.fail("Not authorized"))
                return
            }
            
            let fetchOptions = PHFetchOptions()
            if let limit = limit {
                fetchOptions.fetchLimit = limit
            }
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            
            let results: PHFetchResult<PHAsset>
            
            switch type {
            case .all:
                results = PHAsset.fetchAssets(with: fetchOptions)
            case .images:
                results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            case .videos:
                results = PHAsset.fetchAssets(with: .video, options: fetchOptions)
            }
            
            var resultArray: [MKLibraryAsset] = []
            results.enumerateObjects({ (object, index, _) in
                let asset = MKLibraryAsset()
                
                switch object.mediaType {
                case .image: asset.type = .image
                case .video: asset.type = .video
                default: asset.type = .unknown
                }
                
                asset.duration = object.duration
                asset.phAsset = object
                resultArray.append(asset)
            })
            
            completion(.success(resultArray))
        }
    }
}
