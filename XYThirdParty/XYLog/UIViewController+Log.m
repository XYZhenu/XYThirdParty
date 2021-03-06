//
//  UIViewController+Log.m
//  shell
//
//  Created by xieyan on 2017/3/15.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "UIViewController+Log.h"
#import "Log.h"
@import Social;
@interface _LogFormater : NSObject <DDLogFormatter>

@end
@implementation _LogFormater
- (NSString * __nullable)formatLogMessage:(DDLogMessage *)logMessage{
    return [NSString stringWithFormat:@"%@ file %@.m, line %lu, msg %@",[_LogFormater logLevelStr:logMessage.flag],logMessage.fileName,(unsigned long)logMessage.line,logMessage.message];
}
+(NSString*)logLevelStr:(DDLogFlag)flag{
    switch (flag) {
        case DDLogFlagError:
            return @"【Error】";
        case DDLogFlagInfo:
            return @"【Info】";
        case DDLogFlagWarning:
            return @"【Warning】";
        case DDLogFlagDebug:
            return @"【Debug】";
        default:
            return @"【Verbose】";
    }
}
+(NSString*)logLevel:(DDLogLevel)level{
    switch (level) {
        case DDLogLevelError:
            return @"（Error）";
        case DDLogLevelInfo:
            return @"（Info）";
        case DDLogLevelWarning:
            return @"（Warning）";
        case DDLogLevelDebug:
            return @"（Debug）";
        default:
            return @"（Verbose）";
    }
}
@end
@implementation UIViewController (XYLog)
+(void)load{
    NSString* level = [NSUserDefaults.standardUserDefaults stringForKey:@"log_level"];
    if ([level isEqualToString:@"error"]) {
        ddLogLevel = DDLogLevelError;
    } else if ([level isEqualToString:@"warning"]) {
        ddLogLevel = DDLogLevelWarning;
    } else if ([level isEqualToString:@"info"]) {
        ddLogLevel = DDLogLevelInfo;
    } else if ([level isEqualToString:@"debug"]) {
        ddLogLevel = DDLogLevelDebug;
    } else {
        ddLogLevel = DDLogLevelVerbose;
    }
    
    [DDTTYLogger sharedInstance].logFormatter = [_LogFormater new];
    [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
    
    BOOL log_in_file = [NSUserDefaults.standardUserDefaults boolForKey:@"log_in_file"];
    if (log_in_file) {
        [DDLog removeLogger:[UIViewController fileLogger]];
        [DDLog addLogger:[UIViewController fileLogger] withLevel:ddLogLevel];
    }
}

-(void)addLogGesture{
    UILongPressGestureRecognizer * longGesture =[[UILongPressGestureRecognizer alloc] init];
    longGesture.minimumPressDuration = 1.5;
    [longGesture addTarget:self action:@selector(longPress:)];
    [self.view addGestureRecognizer:longGesture];
}

-(void)longPress:(UILongPressGestureRecognizer*)sender{
    if (sender.state == UIGestureRecognizerStateBegan)
    {
        
        UIAlertController * alertVC = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"Verbose 记录所有日志" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelVerbose;
            [NSUserDefaults.standardUserDefaults setInteger:ddLogLevel forKey:@"ddLogLevel"];
            [DDLog removeLogger:[DDTTYLogger sharedInstance]];
            [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
        }];
        UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"Debug" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelDebug;
            [NSUserDefaults.standardUserDefaults setInteger:ddLogLevel forKey:@"ddLogLevel"];
            [DDLog removeLogger:[DDTTYLogger sharedInstance]];
            [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
        }];
        UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"Info" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelInfo;
            [NSUserDefaults.standardUserDefaults setInteger:ddLogLevel forKey:@"ddLogLevel"];
            [DDLog removeLogger:[DDTTYLogger sharedInstance]];
            [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
        }];
        UIAlertAction * action4 = [UIAlertAction actionWithTitle:@"Warning" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelWarning;
            [NSUserDefaults.standardUserDefaults setInteger:ddLogLevel forKey:@"ddLogLevel"];
            [DDLog removeLogger:[DDTTYLogger sharedInstance]];
            [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
        }];
        UIAlertAction * action5 = [UIAlertAction actionWithTitle:@"Error 只记录错误" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            ddLogLevel = DDLogLevelError;
            [NSUserDefaults.standardUserDefaults setInteger:ddLogLevel forKey:@"ddLogLevel"];
            [DDLog removeLogger:[DDTTYLogger sharedInstance]];
            [DDLog addLogger:[DDTTYLogger sharedInstance] withLevel:ddLogLevel];
        }];
        UIAlertAction * action7 = [UIAlertAction actionWithTitle:@"分享日志" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            DDFileLogger* log = [UIViewController fileLogger];
            UIActivityViewController* act = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:log.currentLogFileInfo.filePath]] applicationActivities:nil];
            [self presentViewController:act animated:YES completion:nil];
        }];
        [alertVC addAction:action1];
        [alertVC addAction:action2];
        [alertVC addAction:action3];
        [alertVC addAction:action4];
        [alertVC addAction:action5];
        [alertVC addAction:action7];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}
+ (void) shareAllLogfiles {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    NSArray* files = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentDirectory error:nil];
    NSMutableArray* logs = [NSMutableArray array];
    for (NSString* file in files) {
        if ([file.pathExtension isEqualToString:@"log"]) {
            [logs addObject:[NSURL fileURLWithPath:file]];
        }
    }
    UIActivityViewController* act = [[UIActivityViewController alloc] initWithActivityItems:logs applicationActivities:nil];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:act animated:YES completion:nil];
}
+(DDFileLogger*)fileLogger{
    static DDFileLogger *fileLogger = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentDirectory = [paths objectAtIndex:0];
        fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc] initWithLogsDirectory:documentDirectory]];
        fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
        fileLogger.maximumFileSize = 0;
        fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    });
    return fileLogger;
}
@end
