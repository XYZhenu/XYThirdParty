//
//  CALayer+ImageLoader.m
//  XYThirdParty
//
//  Created by xieyan on 2017/7/15.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import "CALayer+ImageLoader.h"
#import <FlyImage/CALayer+FlyImageCache.h>
#import <FlyImage/CALayer+FlyImageIconCache.h>
@implementation CALayer (ImageLoader)
-(void)xy_load:(nullable id)url {
    [self xy_load:url placeHolder:nil];
}
-(void)xy_load:(nullable id)url placeHolder:(nullable NSString*)placeHolder {
    NSURL* imageurl = nil;
    if ([url isKindOfClass:[NSString class]]) {
        imageurl = [NSURL URLWithString:url];
    }else if ([url isKindOfClass:[NSURL class]]){
        imageurl = url;
    }else if (!url){
        
    }else{
        return;
    }
    [self setPlaceHolderImageName:placeHolder thumbnailURL:nil originalURL:imageurl];
}
-(void)xy_loadIcon:(nullable id)url {
    [self xy_loadIcon:url placeHolder:nil];
}
-(void)xy_loadIcon:(nullable id)url placeHolder:(nullable NSString*)placeHolder {
    NSURL* imageurl = nil;
    if ([url isKindOfClass:[NSString class]]) {
        imageurl = [NSURL URLWithString:url];
    }else if ([url isKindOfClass:[NSURL class]]){
        imageurl = url;
    }else{
        return;
    }
    [self setPlaceHolderImageName:placeHolder iconURL:imageurl];
}
@end
