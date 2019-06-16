//
//  RichTextVC.m
//  XYThirdParty
//
//  Created by xyzhenu on 2017/6/27.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import "RichTextVC.h"
#import "ImageUploader.h"

@interface RichTextVC ()<XYOperateDelegate>
@property(nonatomic,strong)NSOperationQueue* operqueue;
@property(nonatomic,strong)NSMutableDictionary<NSString*,ImageUploader*>* imagesDic;
@end

@implementation RichTextVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.operqueue = [[NSOperationQueue alloc] init];
    self.operqueue.maxConcurrentOperationCount = 2;
    self.operqueue.name = @"rich_text_uploader";
    self.imagesDic = [NSMutableDictionary dictionary];
    // Do any additional setup after loading the view.
}

-(void)onSaveWithText:(NSString *)content images:(NSDictionary<NSString *,XYRichTextImage *> *)images complete:(BOOL)complete{
    //remove old
    NSSet<NSString*>* current = [NSSet setWithArray:self.imagesDic.allKeys];
    NSSet<NSString*>* discard = [current objectsPassingTest:^BOOL(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        return nil == images[obj];
    }];
    [discard enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        [self.imagesDic[obj] cancel];
        [self.imagesDic removeObjectForKey:obj];
    }];
    
    //add new
    NSSet<NSString*>* new = [NSSet setWithArray:images.allKeys];
    NSSet<NSString*>* added = [new objectsPassingTest:^BOOL(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
        return nil == self.imagesDic[obj];
    }];
    [added enumerateObjectsUsingBlock:^(NSString *  _Nonnull obj, BOOL * _Nonnull stop) {
        ImageUploader* lo = [[ImageUploader alloc] init];
        lo.msg = images[obj];
        lo.group = @"test";
        lo.operDelegate = self;
        [self.imagesDic setValue:lo forKey:obj];
    }];
    if (complete) {
        [self.operqueue addOperations:self.imagesDic.allValues waitUntilFinished:NO];
    }else{
        [added enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, BOOL * _Nonnull stop) {
            [self.imagesDic[obj] save]; 
        }];
    }
}

-(void)uploaderComplete:(ImageUploader *)uploader error:(BOOL)error{
    if (error) {
        ImageUploader* lo = [[ImageUploader alloc] init];
        lo.msg = uploader.msg;
        lo.group = @"test";
        lo.operDelegate = self;
        [self.imagesDic setObject:lo forKey:lo.identifier];
    }
    for (ImageUploader* loader in self.imagesDic.allValues) {
        if (!loader.msg.uploadedUrl) return;
    }
    //TODO:  complete
}
@end
