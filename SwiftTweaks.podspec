Pod::Spec.new do |s|
  s.name         = "SwiftTweaks"
  s.version      = "4.0.2"

  s.summary      = "Tweak your Swift-based app on-device."
  s.description  = "SwiftTweaks is a way to adjust your Swift-based iOS app on-device without needing to recompile. Read more about it on our blog: http://engineering.khanacademy.org/posts/introducing-swifttweaks.htm"

  s.homepage     = "https://github.com/Khan/SwiftTweaks"
  s.screenshots  = "https://raw.githubusercontent.com/Khan/SwiftTweaks/master/Images/SwiftTweaks%20Overview.png"

  s.license      = { :type => "MIT", :file => "LICENSE" }

  s.authors            = "Khan Academy", "Bryan Clark"
  s.social_media_url   = "https://twitter.com/khanacademy"

  s.platform     = :ios, "8.0"

  s.source       = { :git => "https://github.com/Khan/SwiftTweaks.git", :tag => "v4.0.2", :submodules => true }
  s.source_files = "SwiftTweaks/**/*.swift"
  s.resources = "SwiftTweaks/*.xcassets"
  
  s.ios.framework = 'UIKit'

end
