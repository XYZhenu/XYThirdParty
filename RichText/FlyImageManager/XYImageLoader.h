//
//  XYImageLoader.h
//  Pods
//
//  Created by xieyan on 2017/7/24.
//
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN;
@interface XYImageLoader : NSObject
+ (void)loadImage:(NSString*)url complete:(void(^)(UIImage* image))complete;
@end
NS_ASSUME_NONNULL_END;
