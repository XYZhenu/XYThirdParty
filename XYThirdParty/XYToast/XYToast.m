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
    [keyWindow makeToast:text_];
}
@end
