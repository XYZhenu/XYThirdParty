# coding: utf-8
Pod::Spec.new do |s|
    s.name         = "XYThirdParty"
    s.version      = "0.0.2"
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
    s.ios.deployment_target = '9.0'
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
        c.dependency 'MBProgressHUD'
        c.dependency 'MJRefresh'
        c.dependency 'MZTimerLabel'
        c.dependency 'GVUserDefaults'
        c.dependency 'Toast'
    end
    s.subspec 'RichText' do |r|
        r.source_files = 'RichText/RichText/*.{h,m}'
        r.requires_arc = true
        r.dependency 'YYText'
        r.dependency 'YYImage'
        r.dependency 'TZImagePickerController'
    end
    s.subspec 'FlyImage' do |f|
        f.source_files = 'RichText/FlyImageManager/*.{h,m}'
        f.requires_arc = true
        f.dependency 'FlyImage'
    end
end
