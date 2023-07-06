Pod::Spec.new do |spec|
    spec.name = "StreamChatSwiftUI"
    spec.version = "4.34.0"
    spec.summary = "StreamChat SwiftUI Chat Components"
    spec.description = "StreamChatUI SDK offers flexible SwiftUI components able to display data provided by StreamChat SDK."
  
    spec.homepage = "https://getstream.io/chat/"
    spec.license = { :type => "BSD-3", :file => "LICENSE" }
    spec.author = { "getstream.io" => "support@getstream.io" }
    spec.social_media_url = "https://getstream.io"
    spec.swift_version = "5.2"
    spec.platform = :ios, "14.0"
    spec.source = { :git => "https://github.com/GetStream/stream-chat-swiftui.git" }
    spec.requires_arc = true
  
    spec.source_files = "Sources/StreamChatSwiftUI/**/*.swift"
    spec.exclude_files = ["Sources/StreamChatSwiftUI/**/*_Tests.swift", "Sources/StreamChatSwiftUI/**/*_Mock.swift"]
    spec.resource_bundles = { "StreamChatSwiftUI" => ["Sources/StreamChatSwiftUI/Resources/**/*"] }
  
    spec.framework = "Foundation", "UIKit", "SwiftUI"
  
    spec.dependency "StreamChat", "~> 4.34.0"
    spec.dependency "SwiftyGif", "~> 5.0"
    spec.dependency "NukeUI", "0.8.0"
  end
  
