//
//  MKChromeFilter.swift
//  MediaKit
//
//  Created by Adrian Mateoaea on 11/01/2017.
//  Copyright © 2017 Wonderkiln. All rights reserved.
//

import CoreImage

public class MKChromeFilter: MKFilter {
    
    public var displayName: String = "Chrome"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIPhotoEffectChrome")!
    }
}

public class MKFadeFilter: MKFilter {
    
    public var displayName: String = "Fade"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIPhotoEffectFade")!
    }
}

public class MKInstantFilter: MKFilter {
    
    public var displayName: String = "Instant"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIPhotoEffectInstant")!
    }
}

public class MKMonoFilter: MKFilter {
    
    public var displayName: String = "Mono"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIPhotoEffectMono")!
    }
}

public class MKProcessFilter: MKFilter {
    
    public var displayName: String = "Process"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIPhotoEffectProcess")!
    }
}

public class MKSepiaFilter: MKFilter {
    
    public var displayName: String = "Sepia"
    
    public var filter: CIFilter
    
    public var intensity: CGFloat
    
    public init(intensity: CGFloat = 0.5) {
        filter = CIFilter(name: "CISepiaTone")!
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        self.intensity = intensity
    }
}

public class MKVignetteFilter: MKFilter {
    
    public var displayName: String = "Vignette"
    
    public var filter: CIFilter
    
    public var radius: CGFloat
    public var intensity: CGFloat
    
    public init(radius: CGFloat = 0.5, intensity: CGFloat = 0.5) {
        filter = CIFilter(name: "CIVignette")!
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        self.radius = radius
        self.intensity = intensity
    }
}

public class MKPhotoTransferFilter: MKFilter {
    
    public var displayName: String = "Photo Transfer"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIPhotoEffectTransfer")!
    }
}

public class MKTonalFilter: MKFilter {
    
    public var displayName: String = "Tonal"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIPhotoEffectTonal")!
    }
}

public class MKGloomFilter: MKFilter {
    
    public var displayName: String = "Gloom"
    
    public var filter: CIFilter
    
    public var radius: CGFloat
    public var intensity: CGFloat
    
    public init(radius: CGFloat = 15.0, intensity: CGFloat = 0.5) {
        filter = CIFilter(name: "CIGloom")!
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        filter.setValue(intensity, forKey: kCIInputIntensityKey)
        self.radius = radius
        self.intensity = intensity
    }
}

public class MKCrystallizeFilter: MKFilter {
    
    public var displayName: String = "Crystallize"
    
    public var filter: CIFilter
    
    public var radius: CGFloat
    public var center: CIVector
    
    public init(radius: CGFloat = 15.0, center: CIVector = CIVector(x: 150, y: 150)) {
        filter = CIFilter(name: "CICrystallize")!
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        filter.setValue(center, forKey: kCIInputCenterKey)
        self.radius = radius
        self.center = center
    }
}

public class MKInvertFilter: MKFilter {
    
    public var displayName: String = "Invert"
    
    public var filter: CIFilter
    
    public init() {
        filter = CIFilter(name: "CIColorInvert")!
    }
}
