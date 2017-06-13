//
//  XYWebVC.h
//  XYCategories
//
//  Created by xyzhenu on 2017/6/8.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <UIKit/UIKit.h>
static NSString* keyWebVCGET = @"get";
static NSString* keyWebVCUrl = @"url";
static NSString* keyWebVCParma = @"parma";
@interface XYWebVC : UIViewController
//custom load method with subclass and rewrite this method 
-(void)loadIsGet:(BOOL)isGet url:(NSString*)url parma:(NSDictionary*)parma web:(UIWebView*)web;
@end
