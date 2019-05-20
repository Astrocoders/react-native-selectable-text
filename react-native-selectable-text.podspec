require 'json'

package = JSON.parse(File.read(File.join(__dir__, 'package.json')))

Pod::Spec.new do |s|
  s.name         = "react-native-selectable-text"
  s.version      = package['version']
  s.summary      = package['description']
  s.license      = package['license']

  s.authors      = package['author']
  s.homepage     = package['homepage']
  s.platform     = :ios, "9.0"

  s.source       = { :git => "https://github.com/Astrocoders/react-native-selectable-text.git", :tag => "#{s.version}" }
  s.source_files  = "ios/**/*.{h,m}"

  # React is split into a set of subspecs, these are the essentials
  s.dependency 'React/Core'
  s.dependency 'React/CxxBridge'
  s.dependency 'React/RCTAnimation'
  s.dependency 'React/RCTImage'
  s.dependency 'React/RCTLinkingIOS'
  s.dependency 'React/RCTNetwork'
  s.dependency 'React/RCTText'

  # React's dependencies
  podspecs = [
    'node_modules/react-native/third-party-podspecs/DoubleConversion.podspec',
    'node_modules/react-native/third-party-podspecs/Folly.podspec',
    'node_modules/react-native/third-party-podspecs/glog.podspec'
  ]
  podspecs.each do |podspec_path|
    spec = Pod::Specification.from_file podspec_path
    s.dependency spec.name, "#{spec.version}"
  end
end
