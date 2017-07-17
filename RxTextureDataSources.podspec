Pod::Spec.new do |s|
 s.name = 'RxTextureDataSources'
 s.version = '0.1'
 s.license = { :type => "MIT", :file => "LICENSE" }
 s.summary = 'RxDataSource for AsyncDisplayKit/Texture view containers'
 s.homepage = 'https://github.com/dangthaison91/RxTextureDataSources'
 s.social_media_url = 'https://twitter.com/dangthaison91'
 s.authors = { "Dang Thai Son" => "dangthaison.91@gmail.com" }
 s.source = { :git => "https://github.com/dangthaison91/RxTextureDataSources.git", :tag => "v"+s.version.to_s }
 s.platforms     = { :ios => "8.0" }
 s.requires_arc = true

 s.default_subspec = "Core"
 s.subspec "Core" do |ss|
     ss.source_files  = "Sources"
     ss.framework  = "Foundation"
     s.dependency 'RxSwift', '~> 3.4'
     s.dependency 'RxCocoa', '~> 3.4'
     s.dependency 'RxDataSources', '~> 1.0'
     s.dependency 'Texture', '~> 2.0'
 end

end
