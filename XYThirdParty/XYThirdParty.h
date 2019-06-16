//
//  XYThirdParty.h
//  XYThirdParty
//
//  Created by xyzhenu on 2019/6/14.
//  Copyright © 2019 xyzhenu. All rights reserved.
//

#import <UIKit/UIKit.h>
// In this header, you should import all the public headers of your framework using statements like #import <XYThirdParty/PublicHeader.h>


#ifndef XYThirdParty_h
#define XYThirdParty_h

#define View(__TAG__) [theView viewWithTag:__TAG__]
#define Label(__TAG__) ((UILabel*)[theView viewWithTag:__TAG__])
#define Image(__TAG__) ((UIImageView*)[theView viewWithTag:__TAG__])
#define Button(__TAG__) ((UIButton*)[theView viewWithTag:__TAG__])

#define LabelCreate(__TAG__) UILabel* label_##__TAG__ = [[UILabel alloc] init];\
label_##__TAG__.tag = __TAG__;\
[theView addSubview:label_##__TAG__];

#define ImageCreate(__TAG__) UIImageView* image_##__TAG__ = [[UIImageView alloc] init];\
image_##__TAG__.tag = __TAG__;\
image_##__TAG__.contentMode = UIViewContentModeCenter;\
[theView addSubview:image_##__TAG__];

#define ViewCreate(__TAG__) UIView* view_##__TAG__ = [[UIView alloc] init];\
view_##__TAG__.tag = __TAG__;\
[theView addSubview:view_##__TAG__];


#endif /* XYThirdParty_h */

#import <XYThirdParty/UIViewController+ImagePicker.h>
#import <XYThirdParty/UIViewController+DatePicker.h>

#import <XYThirdParty/XYLoadingPage.h>
#import <XYThirdParty/XYToast.h>
#import <XYThirdParty/XYWebVC.h>
#import <XYThirdParty/Log.h>
#import <XYThirdParty/UIViewController+Log.h>
#import <XYThirdParty/XYMenu.h>
#import <XYThirdParty/XYNetwork.h>

#import <XYThirdParty/XYButton.h>
#import <XYThirdParty/XYScroll.h>
#import <XYThirdParty/XYScrollChartView.h>
#import <XYThirdParty/XYSegment.h>
#import <XYThirdParty/XYSlider.h>

#import <XYThirdParty/XYTableViewController.h>
#import <XYThirdParty/XYCollectionViewController.h>
