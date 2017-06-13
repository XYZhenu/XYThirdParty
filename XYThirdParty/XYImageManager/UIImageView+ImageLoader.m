//
//  UIImageView+ImageLoader.m
//  XYCategories
//
//  Created by xyzhenu on 2017/6/12.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "UIImageView+ImageLoader.h"
#import <FlyImage/UIImageView+FlyImageCache.h>
#import <FlyImage/UIImageView+FlyImageIconCache.h>

@implementation UIImageView (XYImageLoader)
-(void)xy_load:(nullable id)url {
    [self xy_load:url placeHolder:nil];
}
-(void)xy_load:(nullable id)url placeHolder:(nullable id)placeHolder {
    NSString* placeholderName = nil;
    if ([placeHolder isKindOfClass:[UIImage class]]) {
        self.image = placeHolder;
    }else if ([placeHolder isKindOfClass:[NSString class]]){
        placeholderName = placeHolder;
    }
    NSURL* imageurl = nil;
    if ([url isKindOfClass:[NSString class]]) {
        imageurl = [NSURL URLWithString:url];
    }else if ([url isKindOfClass:[NSURL class]]){
        imageurl = url;
    }else{
        return;
    }
    [self setPlaceHolderImageName:placeholderName thumbnailURL:nil originalURL:imageurl];
}
-(void)xy_loadIcon:(nullable id)url {
    [self xy_loadIcon:url placeHolder:nil];
}
-(void)xy_loadIcon:(nullable id)url placeHolder:(nullable id)placeHolder {
    NSString* placeholderName = nil;
    if ([placeHolder isKindOfClass:[UIImage class]]) {
        self.image = placeHolder;
    }else if ([placeHolder isKindOfClass:[NSString class]]){
        placeholderName = placeHolder;
    }
    NSURL* imageurl = nil;
    if ([url isKindOfClass:[NSString class]]) {
        imageurl = [NSURL URLWithString:url];
    }else if ([url isKindOfClass:[NSURL class]]){
        imageurl = url;
    }else{
        return;
    }
    [self setPlaceHolderImageName:placeholderName iconURL:imageurl];
}
@end
