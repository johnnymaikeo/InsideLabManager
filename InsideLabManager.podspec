#
# Be sure to run `pod lib lint InsideLabManager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'InsideLabManager'
  s.version          = '0.1.0'
  s.summary          = 'iBeacon Manager provides a simple and optimized framework to easily integrate any iOS application with InsideLab products.'

  s.description      = <<-DESC
InsideLab iBeacon Manager is a framework that makes the work of connecting and reading iBeacons a piece of cake. It uses standard CoreLocation framework instructions allowing your application to easily connect and read any iBeacon. In addition to the simplified configuration and usage, InsideLab iBeacon Manager connects to the InsideLab API generating visitation metrics with a single line of code. If you need more than just metrics, the InsideLab iBeacon Manager allows you to monitor and get alerts to specific iBeacons.
                       DESC

  s.homepage         = 'https://github.com/johnnymaikeo/InsideLabManager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'InsideLab' => 'pod@insidelab.net' }
  s.source           = { :git => 'https://github.com/johnnymaikeo/InsideLabManager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'InsideLabManager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'InsideLabManager' => ['InsideLabManager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
