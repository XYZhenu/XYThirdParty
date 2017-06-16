# coding: utf-8
Pod::Spec.new do |s|

  s.name         = "XYThirdParty"

  s.version      = "0.0.1"

  s.summary      = "XYThirdParty Source ."

  s.description  = <<-DESC
                   xyzhenu framework
                   DESC

  s.homepage     = "https://github.com/XYZhenu"
  s.license = {
    :type => 'Copyright',
    :text => <<-LICENSE
        copyright
    LICENSE
  }
  s.authors      = { "xyzhenu"      => "1515489649@qq.com" }
  s.platform     = :ios
  s.ios.deployment_target = '7.0'
  s.source =  { :path => '.' }
  s.source_files = 'XYThirdParty/*Extention/*.{h,m}','XYThirdParty/XY*/*.{h,m}','XYThirdParty/XYThirdParty.h'
  s.resources = 'XYThirdParty/**/*.png'
#  s.resources = 'XYThirdParty/Resources/main.js', 'XYThirdParty/Resources/cc@3x.png'

  s.requires_arc = true
#  s.prefix_header_file = 'XYThirdParty/XYThirdParty-Prefix.pch'

#  s.xcconfig = { "GCC_PREPROCESSOR_DEFINITIONS" => '$(inherited) DEBUG=1' }

  s.xcconfig = { "OTHER_LINK_FLAG" => '$(inherited) -ObjC'}

  s.user_target_xcconfig  = { 'FRAMEWORK_SEARCH_PATHS' => "'$(PODS_ROOT)/XYThirdParty'" }

#  s.frameworks = 'CoreMedia','MediaPlayer','AVFoundation','AVKit','JavaScriptCore', 'GLKit'

  s.dependency 'TZImagePickerController'
  s.dependency 'TAPageControl'
  s.dependency 'AFNetworking'
  s.dependency 'CocoaLumberjack'
  s.dependency 'NJKWebViewProgress'
  s.dependency 'MBProgressHUD'
  s.dependency 'MJRefresh'
  s.dependency 'FlyImage'
  s.dependency 'MZTimerLabel'
#  s.libraries = "stdc++"

s.subspec 'JSON' do |json|
json.source_files = 'XYThirdParty/JSON/*.{h,m}'
json.requires_arc = false
end

end
