Pod::Spec.new do |s|
  s.name         = 'YJFloatingView'
  s.version      = '1.0.0'
  s.summary      = 'A simple custom floating ball view.'
  s.description  = <<-DESC
                   This is floating ball view.
                   DESC
  # ⚠️ 这里先填个假的，等下上传GitHub后回来改
  s.homepage     = 'https://github.com/YongJoan/YJFloatingView.git'
  s.license      = { :type => 'MIT', :file => 'LICENSE' }
  s.author       = { 'jade' => 'bj_yj1991@126.com' } # ⚠️改成你的名字和邮箱
  
  # ⚠️ 这里也先填个假的
  s.source       = { :git => 'https://github.com/YongJoan/YJFloatingView.git', :tag => s.version.to_s }
  
  s.platform     = :ios, '10.0'
  s.source_files = '**/*.{h,m,mm,c,swift}'
  s.frameworks   = 'UIKit'
end
