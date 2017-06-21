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
    s.xcconfig = { "OTHER_LINK_FLAG" => '$(inherited) -ObjC'}
    s.user_target_xcconfig  = { 'FRAMEWORK_SEARCH_PATHS' => "'$(PODS_ROOT)/XYThirdParty'" }
#    s.frameworks = 'CoreMedia','MediaPlayer','AVFoundation','AVKit','JavaScriptCore', 'GLKit'
#    s.libraries = "stdc++"

    s.subspec 'Core' do |c|
        c.source_files = 'XYThirdParty/*Extention/*.{h,m}','XYThirdParty/XY*/*.{h,m}','XYThirdParty/XYThirdParty.h'
        c.resources = 'XYThirdParty/**/*.png'
        c.requires_arc = true
        c.dependency 'TZImagePickerController'
        c.dependency 'TAPageControl'
        c.dependency 'AFNetworking'
        c.dependency 'CocoaLumberjack'
        c.dependency 'NJKWebViewProgress'
        c.dependency 'MBProgressHUD'
        c.dependency 'MJRefresh'
        c.dependency 'FlyImage'
        c.dependency 'MZTimerLabel'
        c.dependency 'GVUserDefaults'
    end
    s.subspec 'JSON' do |json|
        json.source_files = 'XYThirdParty/JSON/*.{h,m}'
        json.requires_arc = false
    end

end
