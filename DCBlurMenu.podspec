Pod::Spec.new do |s|
  s.name         =  'DCBlurMenu'
  s.version      =  '0.0.1'
  s.license      =  'MIT'
  s.summary      =  'A blurred swipe down menu designed for iOS.'
  s.description  =  'DCBlurMenu is a beautiful blurred dropdown navigation menu without any performance problems.'
  s.author       =  { 'David Chavez' => 'https://twitter.com/dchavezlive' }
  s.source       =  { :git => 'https://github.com/dchavezlive/DCBlurMenu.git' , :tag => '0.0.1' }
  s.homepage     =  'https://github.com/dchavezlive/DCBlurMenu'
  s.platform     =  :ios
  s.source_files =  'DCBlurMenu'
  s.requires_arc =  true
  s.dependency "ILTranslucentView", "~> 0.0.1"
  s.ios.deployment_target = '7.0'
end
