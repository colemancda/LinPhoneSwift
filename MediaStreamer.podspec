Pod::Spec.new do |s|
  s.name = 'MediaStreamer'
  s.version = '1.0.0'
  s.summary = 'Linphone for Swift'
  s.license = 'MIT'
  s.authors = { "Alsey Coleman Miller" => "colemancda.github.io" }
  s.homepage = 'http://github.com/coleman/LinPhoneSwift'
  s.description = 'Swift library for Linphone'
  s.requires_arc = true
  s.ios.deployment_target  = '8.0'
  s.osx.deployment_target  = '10.10'
  s.source = { :path => '*' }
  s.source_files = 'Sources/MediaStreamer/*.swift'
  s.ios.vendored_frameworks = '$SRCROOT/../liblinphone-sdk/iOS/apple-darwin/Frameworks/*.framework'
  s.ios.xcconfig = { 
    'ENABLE_BITCODE' => 'NO',
    'SWIFT_INCLUDE_PATHS' => '$SRCROOT/../liblinphone-sdk/Modules/CBelledonneRTP $SRCROOT/../liblinphone-sdk/Modules/CBelledonneSIP $SRCROOT/../liblinphone-sdk/Modules/CBelledonneToolbox $SRCROOT/../liblinphone-sdk/Modules/CLinPhone $SRCROOT/../liblinphone-sdk/Modules/CMediaStreamer2', 
    'FRAMEWORK_SEARCH_PATHS' => '$SRCROOT/../liblinphone-sdk/iOS/apple-darwin/Frameworks',
    'LIBRARY_SEARCH_PATHS' => '$SRCROOT/../liblinphone-sdk/iOS/apple-darwin/lib',
    'OTHER_LDFLAGS' => '-lbcg729 -framework mediastreamer_base -framework mediastreamer_voip -framework msamr -framework msopenh264 -framework mssilk -framework mswebrtc -framework msx264'
   }
   s.ios.library = 'xml2', 'sqlite3'
   s.dependency 'BelledonneToolbox'
   s.dependency 'BelledonneRTP'
   s.ios.frameworks = 'CoreMedia', 'CoreVideo', 'VideoToolbox', 'QuartzCore', 'AudioToolbox', 'AVFoundation', 'UIKit', 'CoreGraphics', 'OpenGLES'
end