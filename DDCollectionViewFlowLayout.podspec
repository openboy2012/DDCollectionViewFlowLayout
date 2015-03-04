Pod::Spec.new do |s|
 s.name     = 'DDCollectionViewFlowLayout'
 s.version  = '0.3'
 s.license  = 'MIT'
 s.summary  = 'a CollectionViewFlowLayout implement the Waterfall Effect'
 s.homepage = 'https://github.com/openboy2012/DDCollectionViewFlowLayout.git'
 s.author   = { 'DeJohn Dong' => 'dongjia_9251@126.com' }
 s.source   = { :git => 'https://github.com/openboy2012/DDCollectionViewFlowLayout.git',:tag =>s.version.to_s }
 s.ios.deployment_target = '6.0' 
 s.source_files = 'DDCollectionViewFlowLayout/Classes/*.{h,m}'
 s.requires_arc = true
 s.frameworks = 'UIKit'
end
