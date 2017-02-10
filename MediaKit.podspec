Pod::Spec.new do |s|
  s.name     = "MediaKit"
  s.version  = "0.0.7"
  s.summary  = "MediaKit"
  s.homepage = "https://github.com/wonderkiln/MediaKit"
  s.license  = { :type => "MIT License", :file => "LICENSE" }
  s.author   = { "Adrian Mateoaea" => "adrianitech@gmail.com" }
  s.source   = { :git => "https://github.com/wonderkiln/MediaKit", :tag => "#{s.version}" }

  s.ios.deployment_target = "9.0"

  s.source_files = "MediaKit/*.swift"
  s.resources    = "MediaKit/*.{xib,storyboard,xcassets}"
end
