

Pod::Spec.new do |spec|
  spec.name         = 'YXURLSchemeHandler'
  spec.summary      = 'YXURLSchemeHandler'
  spec.version      = '0.0.1'
  
  spec.ios.deployment_target  = '11.0'
  spec.license      = { :type => 'MIT' }
  spec.homepage     = 'https://www.baidu.com'
  spec.authors      = { 'o.o.c.' => '568071718@qq.com' }
  spec.source       = { :git => 'https://gitee.com/568071718/url-scheme-handler.git', :tag => "v#{spec.version}" }
  
  spec.source_files = 'lib/**/*.{h,m}'
  # spec.framework    = ''
  # spec.dependency 'Masonry'
end
