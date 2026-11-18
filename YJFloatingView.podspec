Pod::Spec.new do |s|
  s.name         = 'YJFloatingView'
  s.version      = '1.0.0'
  s.summary      = 'A simple custom floating ball view.'
  s.description  = <<-DESC
                   This is floating ball view.
                   DESC
  s.homepage     = 'https://github.com/YongJoan/YJFloatingView.git'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'jade' => 'bj_yj1991@126.com' }
  
  s.source       = { :git => 'https://github.com/YongJoan/YJFloatingView.git', :tag => s.version.to_s }
  
  s.platform     = :ios
  s.source_files = '**/*.{h,m,mm,c,swift}'
  s.ios.deployment_target = '10.0'
end
