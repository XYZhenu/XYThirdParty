//
//  XYWebVC.h
//  XYCategories
//
//  Created by xyzhenu on 2017/6/8.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
static NSString* keyWebVCGET = @"get";
static NSString* keyWebVCUrl = @"url";
static NSString* keyWebVCParma = @"parma";
@interface XYWebVC : UIViewController
@property(nonatomic,assign)BOOL alwaysHideTabbar;//default NO;

-(void)bindWebView:(WKWebView*)webView;
-(void)loadFromParma;
- (void)addWebviewReturnButton:(id _Nullable)content;
//custom load method with subclass and rewrite this method
-(void)loadIsGet:(BOOL)isGet url:(NSString*)url parma:(NSDictionary* _Nullable)parma web:(WKWebView*)web;
@end
NS_ASSUME_NONNULL_END
