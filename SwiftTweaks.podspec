#
# Be sure to run `pod lib lint SwiftTweaks.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "SwiftTweaks"
  s.version          = "1.0"
  s.summary          = "Tweak your iOS app without recompiling!"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!
  s.description      = <<-DESC
                        Use a Tweak in place of a boolean, number, or color in your code. You can adjust that Tweak without having to recompile, which means you can play with animation timings, colors, and layouts without needing Xcode!
                       DESC

  s.homepage         = "https://github.com/Khan/SwiftTweaks"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "Bryan Clark" => "contact@bryanjclark.com" }
  s.source           = { :git => "https://github.com/Khan/SwiftTweaks.git", :tag => s.version.to_s }

  s.ios.deployment_target = '8.0'
  s.requires_arc = true

  s.source_files = "SwiftTweaks"
  s.resources = "SwiftTweaks/*.xcassets"

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.dependency 'AFNetworking', '~> 2.3'
end
