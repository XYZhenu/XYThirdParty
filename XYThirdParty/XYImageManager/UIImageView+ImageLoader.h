//
//  UIImageView+ImageLoader.h
//  XYCategories
//
//  Created by xyzhenu on 2017/6/12.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN
@interface UIImageView (XYImageLoader)
-(void)xy_load:(nullable id)url;
-(void)xy_load:(nullable id)url placeHolder:(nullable NSString*)placeHolder;
-(void)xy_loadIcon:(nullable id)url;
-(void)xy_loadIcon:(nullable id)url placeHolder:(nullable NSString*)placeHolder;
@end
NS_ASSUME_NONNULL_END
