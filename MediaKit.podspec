Pod::Spec.new do |spec|
  spec.name     = "MediaKit"
  spec.version  = "0.0.1"
  spec.summary  = "MediaKit"
  spec.homepage = "https://github.com/wonderkiln/MediaKit"
  spec.license  = { :type => "MIT License", :file => "LICENSE" }
  spec.author   = { "Adrian Mateoaea" => "adrianitech@gmail.com" }

  spec.ios.deployment_target = "9.0"

  spec.source       = { :git => "https://github.com/wonderkiln/MediaKit", :tag => "#{spec.version}" }
  spec.source_files = "MediaKit/*.swift"
  spec.resources    = "MediaKit/*.{xib,storyboard}"

  spec.dependency "MARKRangeSlider", "~> 1.1"
end
