Pod::Spec.new do |s|
     s.name = 'RxASDataSources'
     s.version = '0.3'
     s.license = { :type => "MIT", :file => "LICENSE" }
     s.summary = 'RxDataSources for AsyncDisplayKit/Texture ASTableNode/ASCollectionNode'
     s.homepage = 'https://github.com/dangthaison91/RxASDataSources'
     s.social_media_url = 'https://twitter.com/dangthaison91'
     s.authors = { "Dang Thai Son" => "dangthaison.91@gmail.com" }
     s.source = { :git => "https://github.com/dangthaison91/RxASDataSources.git", :tag => s.version.to_s }
     s.platforms     = { :ios => "8.0" }
     s.requires_arc = true

     s.source_files  = "Sources/**/*.swift"
     s.framework  = "Foundation"
     s.dependency 'RxSwift', '~> 4.0'
     s.dependency 'RxCocoa', '~> 4.0'
     s.dependency 'Differentiator', '~> 3.0'
     s.dependency 'Texture', '~> 2.5'

end
