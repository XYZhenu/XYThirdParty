//
//  CALayer+ImageLoader.h
//  XYThirdParty
//
//  Created by xieyan on 2017/7/15.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

NS_ASSUME_NONNULL_BEGIN
@interface CALayer (ImageLoader)
-(void)xy_load:(nullable id)url;
-(void)xy_load:(nullable id)url placeHolder:(nullable NSString*)placeHolder;
-(void)xy_loadIcon:(nullable id)url;
-(void)xy_loadIcon:(nullable id)url placeHolder:(nullable NSString*)placeHolder;
@end
NS_ASSUME_NONNULL_END
