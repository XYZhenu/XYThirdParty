//
//  XYImageLoader.m
//  Pods
//
//  Created by xieyan on 2017/7/24.
//
//

#import "XYImageLoader.h"
#import <FlyImage/FlyImageCache.h>
#import <FlyImage/FlyImageDownloader.h>
@implementation XYImageLoader
+(void)loadImage:(NSString *)url complete:(void (^)(UIImage *))complete {
    if ([[FlyImageCache sharedInstance] isImageExistWithKey:url]) {
        [[FlyImageCache sharedInstance] asyncGetImageWithKey:url completed:^(NSString *key, UIImage *image) {
            complete(image);
        }];
    } else {
        NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:url]];
        request.timeoutInterval = 30;	// Default 30 seconds
        [[FlyImageDownloader sharedInstance] downloadImageForURLRequest:request success:^(NSURLRequest *request, NSURL *filePath) {
            [[FlyImageCache sharedInstance] addImageWithKey:url filename:filePath.lastPathComponent completed:nil];
            complete([UIImage imageWithContentsOfFile:filePath.absoluteString]);
        } failed:^(NSURLRequest *request, NSError *error) {
            
        }];
    }
}
@end
