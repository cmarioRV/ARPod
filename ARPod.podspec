#
# Be sure to run `pod lib lint ARPod.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'ARPod'
  s.version          = '1.0.0'
  s.summary          = 'Library used for testing new AR features'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Library used for testing new AR features. This is for a client
                       DESC

  s.homepage         = 'https://github.com/cmarioRV/ARPod'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Mario Vargas' => 'mariomad18@gmail.com' }
  s.source           = { :git => 'https://github.com/cmarioRV/ARPod.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '4.1'
  s.ios.deployment_target = '13.0'

  s.source_files = 'ARPod/Classes/**/*'
  
   s.resource_bundles = {
     'ARPod' => ['ARPod/Assets/*']
   }

  # s.public_header_files = 'Pod/Classes/**/*.h'
   s.frameworks = 'UIKit', 'QuartzCore'
  # s.dependency 'AFNetworking', '~> 2.3'
end
