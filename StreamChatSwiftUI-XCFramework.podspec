Pod::Spec.new do |spec|
  spec.name = "StreamChatSwiftUI-XCFramework"
  spec.version = "4.40.0"
  spec.summary = "StreamChat SwiftUI Chat Components"
  spec.description = "StreamChatSwiftUI SDK offers flexible SwiftUI components able to display data provided by StreamChat SDK."

  spec.homepage = "https://getstream.io/chat/"
  spec.license = { :type => "BSD-3", :file => "LICENSE" }
  spec.author = { "getstream.io" => "support@getstream.io" }
  spec.social_media_url = "https://getstream.io"
  spec.swift_version = '5.2'
  spec.platform = :ios, "14.0"
  spec.requires_arc = true

  spec.module_name = "StreamChatSwiftUI"
  spec.source = { :http => "https://github.com/GetStream/stream-chat-swiftui/releases/download/#{spec.version}/#{spec.module_name}.zip" }
  spec.vendored_frameworks = "#{spec.module_name}.xcframework"
  spec.preserve_paths = "#{spec.module_name}.xcframework/*"

  spec.framework = "Foundation", "UIKit", "SwiftUI"

  spec.dependency "StreamChat-XCFramework", "~> 4.39.0"

  spec.cocoapods_version = ">= 1.11.0"
end
