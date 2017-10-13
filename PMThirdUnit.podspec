Pod::Spec.new do |s|

  s.name         = "PMThirdUnit"
  s.version      = "4.5.0"
  s.summary      = "贵金属项目所使用的第三方组件(非UI部分)"
  s.homepage     = "https://git.ms.netease.com/preciousmetals/PMThirdUnit"
  s.license      = { :type => 'MIT', :file => 'LICENSE'}
  s.author       = { "YangXP" => "bjyangxiaopeng1@corp.netease.com" }
  s.source       = { :git => "https://git.ms.netease.com/preciousmetals/PMThirdUnit.git", :tag => s.version.to_s}

#  s.source_files = 'PMThirdUnit/PMThirdUnit.m'
  s.platform = :ios
  s.ios.deployment_target = '8.0'

  s.ios.vendored_frameworks = 'Frameworks/PMThirdUnit.framework'

end
