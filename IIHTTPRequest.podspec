#
# Be sure to run `pod lib lint IIHTTPRequest.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'IIHTTPRequest'
  s.version          = '2.0.21'
  s.summary          = 'IIHTTPRequest'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  IIHTTPRequest
  网络请求库SDK - IHTTTPRequest From 2.0.0

                       DESC

  s.homepage         = 'https://github.com/hatjs880328s/IIHTTPRequest'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'hatjs880328s' => 'shanwzh@inspur.com' }
  s.source           = { :git => 'https://github.com/hatjs880328s/IIHTTPRequest.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  s.ios.deployment_target = '8.0'

  # s.source_files = 'IIHTTPRequest/Classes/**/*'

  s.subspec 'Connectivity' do |ss|
      ss.source_files = 'IIHTTPRequest/Classes/Connectivity/**/*'
      ss.dependency 'IIHTTPRequest/RealReachability'
  end

  s.subspec 'HTTPRequest' do |ss|
      ss.source_files = 'IIHTTPRequest/Classes/HTTPRequest/*.*'
      ss.dependency 'IIHTTPRequest/HTTPSource'
      ss.dependency 'IIHTTPRequest/RealReachability'
      ss.dependency 'IIHTTPRequest/Connectivity'
  end

  s.subspec 'HTTPSource' do |ss|
      ss.source_files = 'IIHTTPRequest/Classes/HTTPSource/*.*'
      # ss.dependency 'IIHTTPRequest/Cache'
  end

  s.subspec 'RealReachability' do |ss|
      ss.source_files = 'IIHTTPRequest/Classes/RealReachability/**/*'
      # ss.dependency 'IIHTTPRequest/Cache'
  end
  
  # s.resource_bundles = {
  #   'IIHTTPRequest' => ['IIHTTPRequest/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'II18N'
end
