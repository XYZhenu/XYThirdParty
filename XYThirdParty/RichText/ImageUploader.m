//
//  ImageUploader.m
//  XYThirdParty
//
//  Created by xyzhenu on 2017/6/26.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import "ImageUploader.h"
#import <FlyImage/FlyImage.h>
#import <TZImagePickerController/TZImageManager.h>
#import <YYImage/YYImage.h>
#import "XYRichTextVC.h"
@interface ImageUploader (){
    BOOL executing;
    BOOL finished;
}
@property (nonatomic,strong)NSString* cachePathImage;
@property (nonatomic,strong)NSPort* port;
@property (nonatomic,strong)NSRunLoop* loop;
@end
@implementation ImageUploader
#pragma mark -- archive & unarchive
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.cachePathImage = [coder decodeObjectForKey:@"cachePathImage"];
        self.msg = [XYRichTextImage new];
        self.msg.uploadedUrl = [coder decodeObjectForKey:@"uploadedUrl"];
        self.msg.identifier = [coder decodeObjectForKey:@"identifier"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cachePathImage forKey:@"cachePathImage"];
    [aCoder encodeObject:self.identifier forKey:@"identifier"];
    [aCoder encodeObject:self.msg.uploadedUrl forKey:@"uploadedUrl"];
}
-(void)save {
    [NSKeyedArchiver archiveRootObject:self toFile:[self pathOfArchive]];
}
+(NSArray<ImageUploader*>*)instancesOfGroup:(NSString*)group{
    BOOL isdir = NO;
    if ([[NSFileManager defaultManager] fileExistsAtPath:[self pathOfGroup:group] isDirectory:&isdir] && isdir) {
        NSMutableArray* instances = [NSMutableArray array];
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:[self pathOfGroup:group] error:nil];
        for (NSString* item in contents) {
            if ([item hasSuffix:@".archive"]) {
                [instances addObject:[NSKeyedUnarchiver unarchiveObjectWithFile:item]];
            }
        }
        return instances;
    }
    return nil;
}

#pragma mark -- operation
- (id)init {
    if(self = [super init])
    {
        executing = NO;
        finished = NO;
    }
    return self;
}
- (BOOL)isConcurrent {
    return YES;
}
- (BOOL)isExecuting {
    return executing;
}
- (BOOL)isFinished {
    return finished;
}
- (void)start {
    
    NSLog(@"start current thread %@",[NSThread currentThread]);
    //第一步就要检测是否被取消了，如果取消了，要实现相应的KVO
    if ([self isCancelled]) {
        [self willChangeValueForKey:@"isFinished"];
        finished = YES;
        [self didChangeValueForKey:@"isFinished"];
        return;
    }

    //如果没被取消，开始执行任务
    [self willChangeValueForKey:@"isExecuting"];
    executing = YES;
    [self didChangeValueForKey:@"isExecuting"];

    self.loop = [NSRunLoop currentRunLoop];
    self.port = [NSPort port];
    [self.loop addPort:self.port forMode:NSDefaultRunLoopMode];
    [self.loop performSelector:@selector(main) target:self argument:nil order:0 modes:@[UITrackingRunLoopMode]];
    [self.loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
//    BOOL shouldKeepRunning = YES; // global
//    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
//    while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}
-(void)main{
    [self convert:^(NSData* imageData) {
        [self processData:imageData complete:^(NSString *completeKey) {
            [self.loop performSelector:@selector(completeWithKey:) target:self argument:completeKey order:0 modes:@[UITrackingRunLoopMode]];
        }];
    }];
}
-(void)suspend {
    [self save];
}
-(void)cancel {
    
}



#pragma mark -- process
-(void)completeWithKey:(NSString*)completeKey{
    self.msg.uploadedUrl = completeKey;
    [self changeMsgKey:self.msg.identifier newKey:completeKey];
    [self.port invalidate];
    [self.loop removePort:self.port forMode:UITrackingRunLoopMode];
    self.port = nil;
    CFRunLoopStop(self.loop.getCFRunLoop);
    self.loop = nil;
}
-(void)convert:(void(^)(NSData* newMsg))complete {
    if (self.cachePathImage) {
        complete([NSData dataWithContentsOfFile:self.cachePathImage]);
        return;
    }
    if (!self.msg.asset && self.msg.image) {
        NSData* data = self.msg.image.yy_imageDataRepresentation;
        [self save:data];
        complete(data);
        return;
    }
    if ([[self.msg.asset valueForKey:@"filename"] hasSuffix:@"GIF"] || self.msg.isSelectOriginalPhoto){
        [[TZImageManager manager] getOriginalPhotoDataWithAsset:self.msg.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            [self.loop performSelector:@selector(save:) target:self argument:data order:0 modes:@[UITrackingRunLoopMode]];
            complete(data);
        }];
        return;
    }
    if(self.msg.asset){
        [[TZImageManager manager] getPhotoWithAsset:self.msg.asset photoWidth:1024 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            NSData* data = UIImageJPEGRepresentation(photo, 0.7);
            [self.loop performSelector:@selector(save:) target:self argument:data order:0 modes:@[UITrackingRunLoopMode]];
            complete(data);
        }];
    }
}
-(void)save:(NSData*)imageData{
    self.cachePathImage = [self imagePath:self.msg.identifier];
    [imageData writeToFile:self.cachePathImage atomically:YES];
    [[FlyImageCache sharedInstance] addImageWithKey:self.msg.identifier filename:self.msg.identifier completed:nil];
    [[FlyImageCache sharedInstance] protectFileWithKey:self.msg.identifier];
}
-(void)changeMsgKey:(NSString*)oldKey newKey:(NSString*)newKey {
    [[FlyImageCache sharedInstance] unProtectFileWithKey:oldKey];
    [[FlyImageCache sharedInstance] changeImageKey:oldKey newKey:newKey];
}

-(void)processData:(NSData*)imageData complete:(void(^)(NSString* completeKey))complete {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        complete(@"http://www.baidu.com");
    });
}

-(void)dealloc{
    NSLog(@"dealloc current thread %@",[NSThread currentThread]);
}

#pragma mark -- pathes
-(NSString*)imagePath:(NSString*)name{
    return [[NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject] stringByAppendingFormat:@"/flyImage/files/%@",name];
}
+(NSString*)cachePath{
    return [[NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject] stringByAppendingString:@"/imageuploader"];
}
+(NSString*)pathOfGroup:(NSString*)group{
    return [[self cachePath] stringByAppendingFormat:@"/%@",group];
}
-(NSString*)pathOfArchive{
    return [[ImageUploader pathOfGroup:self.group] stringByAppendingFormat:@"%@.archive",[self.identifier stringByReplacingOccurrencesOfString:@"." withString:@""]];
}
-(NSString *)identifier{
    return self.msg.identifier;
}

@end
