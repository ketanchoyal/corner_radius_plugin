#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint corner_radius_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'corner_radius_plugin'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin to get device screen corner radius'
  s.description      = <<-DESC
Flutter plugin to get device screen corner radius on Android and iOS.
Android uses native RoundedCorner API, iOS uses BezelKit JSON data.
                       DESC
  s.homepage         = 'https://github.com/yourusername/corner-radius-plugin'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Name' => 'your.email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '13.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
  s.swift_version = '5.0'

  # If your plugin requires a privacy manifest, for example if it uses any
  # required reason APIs, update the PrivacyInfo.xcprivacy file to describe your
  # plugin's privacy impact, and then uncomment this line. For more information,
  # see https://developer.apple.com/documentation/bundleresources/privacy_manifest_files
  # s.resource_bundles = {'corner_radius_plugin_privacy' => ['Resources/PrivacyInfo.xcprivacy']}
end
