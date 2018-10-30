//
//  XYToast.m
//
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import "XYToast.h"
#import <Toast/UIView+Toast.h>
#define keyWindow UIApplication.sharedApplication.keyWindow
@implementation XYToast
+ (void)showWithText:(NSString *)text_ {
    [keyWindow makeToast:text_ duration:[CSToastManager defaultDuration] position:[NSValue valueWithCGPoint:CGPointMake(keyWindow.frame.size.width/2, keyWindow.frame.size.height-80)] style:nil];
}
+ (void)showTextOnTop:(NSString *)text_ {
    static NSInteger position = 0;
    static NSString* previousText = nil;
    if (position<0) position = 0;
    if ([previousText isEqualToString:text_]) {
        return;
    } else {
        previousText = text_;
    }
    [keyWindow makeToast:text_ duration:[CSToastManager defaultDuration] position:[NSValue valueWithCGPoint:CGPointMake(keyWindow.frame.size.width/2, keyWindow.frame.size.height/3 + position * 40)] title:nil image:nil style:nil completion:^(BOOL didTap) {
        position --;
    }];
    position ++;
}
@end
