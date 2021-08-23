Pod::Spec.new do |s|
     s.name = 'RxASDataSources'
     s.version = '2.0.0'
     s.license = { :type => "MIT", :file => "LICENSE" }
     s.summary = 'RxDataSources for AsyncDisplayKit/Texture supports ASTableNode/ASCollectionNode'
     s.homepage = 'https://github.com/RxSwiftCommunity/RxASDataSources'
     s.social_media_url = 'https://twitter.com/dangthaison91'
     s.authors = { "Dang Thai Son" => "dangthaison.91@gmail.com" }
     s.source = { :git => "https://github.com/RxSwiftCommunity/RxASDataSources.git", :tag => s.version.to_s }

     s.ios.deployment_target = '9.0'
     s.requires_arc = true
     s.swift_versions = '5.0'

     s.source_files  = "Sources/**/*.swift"
     s.framework  = "Foundation"

     s.dependency 'RxSwift', '~> 6.2'
     s.dependency 'RxCocoa', '~> 6.2'
     s.dependency 'Differentiator', '~> 5.0'
     s.dependency 'Texture', '~> 3.0'

end
