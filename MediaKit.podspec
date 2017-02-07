Pod::Spec.new do |s|
  s.name     = "MediaKit"
  s.version  = "0.0.5"
  s.summary  = "MediaKit"
  s.homepage = "https://github.com/wonderkiln/MediaKit"
  s.license  = { :type => "MIT License", :file => "LICENSE" }
  s.author   = { "Adrian Mateoaea" => "adrianitech@gmail.com" }
  s.source   = { :git => "https://github.com/wonderkiln/MediaKit", :tag => "#{s.version}" }

  s.ios.deployment_target = "9.0"
  s.watchos.deployment_target = "2.0"

  s.default_subspec = "Core"

  s.subspec "Core" do |core|
    core.source_files = "MediaKit/*.swift"
    core.resources    = "MediaKit/*.{xib,storyboard,xcassets}"
    core.dependency "MARKRangeSlider", "~> 1.1"
  end
  
  s.subspec "WebP" do |webp|
      webp.source_files = "MediaKit/WebP*.swift"
      webp.dependency "YYImage", "~> 1.0"
      webp.dependency "MediaKit/Core"
  end
end
