//
//  UIViewController+Log.m
//  shell
//
//  Created by xieyan on 2017/3/15.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "UIViewController+Log.h"
#import "Log.h"
@interface _LogFormater : NSObject <DDLogFormatter>

@end
@implementation _LogFormater
- (NSString * __nullable)formatLogMessage:(DDLogMessage *)logMessage{
    return [NSString stringWithFormat:@"file %@, function %@, line %ld, msg %@",logMessage.fileName,logMessage.function,logMessage.line,logMessage.message];
}

@end
@implementation UIViewController (XYLog)
+(void)load{
    [DDTTYLogger sharedInstance].logFormatter = [_LogFormater new];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
}
-(void)addLogGesture{
#ifdef DEBUG
    UILongPressGestureRecognizer * longGesture =[[UILongPressGestureRecognizer alloc] init];
    longGesture.minimumPressDuration = 2.0;
    [longGesture addTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longGesture];
#endif
}

-(void)longPress:(UILongPressGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"Verbose" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelVerbose;
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"Debug" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelDebug;
        }];
        UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelInfo;
        }];
        UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"Warning" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelWarning;
        }];
        UIAlertAction * action5 = [UIAlertAction actionWithTitle:@"Error" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelError;
        }];
        [alertVC addAction:action1];
        [alertVC addAction:action2];
        [alertVC addAction:action3];
        [alertVC addAction:action4];
        [alertVC addAction:action5];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

@end
