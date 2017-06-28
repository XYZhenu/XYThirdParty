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
@property (nonatomic,strong)NSString* uploadedUrl;

@property (nonatomic,strong)NSPort* port;
@property (nonatomic,strong)NSRunLoop* loop;
@property (nonatomic,strong)NSThread* thread;
@property (nonatomic,strong)id<XYOperateProtocol>operation;
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
    [aCoder encodeObject:self.uploadedUrl forKey:@"uploadedUrl"];
}
-(void)saveArchive {
    self.cachePathImage = [self imagePath:self.msg.identifier];
    [NSKeyedArchiver archiveRootObject:self toFile:[self pathOfArchive]];
}
+(NSArray<ImageUploader*>*)instancesOfGroup:(NSString*)group{
    BOOL isdir = NO;
    NSString* groupPath = [self pathOfGroup:group];
    if ([[NSFileManager defaultManager] fileExistsAtPath:groupPath isDirectory:&isdir] && isdir) {
        NSMutableArray* instances = [NSMutableArray array];
        NSArray* contents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:groupPath error:nil];
        for (NSString* item in contents) {
            if ([item hasSuffix:@".archive"]) {
                [instances addObject:[NSKeyedUnarchiver unarchiveObjectWithFile:[groupPath stringByAppendingPathComponent:item]]];
            }
        }
        return instances;
    }
    return nil;
}
-(void)save {
    [self convert:nil];
    [self saveArchive];
    NSLog(@"saved %@",self.identifier);
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
    
    NSLog(@"start process %@",self.identifier);
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

    if (!self.msg.uploadedUrl) {
        self.thread = [NSThread currentThread];
        self.loop = [NSRunLoop currentRunLoop];
        self.port = [NSPort port];
        [self.loop addPort:self.port forMode:NSDefaultRunLoopMode];
        [self.loop performSelector:@selector(main) target:self argument:nil order:0 modes:@[NSDefaultRunLoopMode]];
        [self.loop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }else{
        NSLog(@"no self.msg.uploadedUrl");
    }

//    BOOL shouldKeepRunning = YES; // global
//    NSRunLoop *theRL = [NSRunLoop currentRunLoop];
//    while (shouldKeepRunning && [theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]]);
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (self.msg.uploadedUrl) {
            [self.operDelegate uploaderComplete:self error:NO];
        }else{
            [self.operDelegate uploaderComplete:self error:YES];
        }
    });
    NSLog(@"finish process %@   result  %@",self.identifier,self.msg.uploadedUrl);
    [self willChangeValueForKey:@"isExecuting"];
    executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    
    [self willChangeValueForKey:@"isFinished"];
    finished = YES;
    [self didChangeValueForKey:@"isFinished"];
}
-(void)main{
    [self convert:^(NSData* imageData) {
        self.operation = [self processData:imageData complete:^(NSString *completeKey) {
            [self performSelector:@selector(completeWithKey:) onThread:self.thread withObject:completeKey waitUntilDone:NO];
        }];
    }];
}
-(void)cancel {
    [super cancel];
    if (self.operation) {
        [self.operation cancel];
    }
    [[FlyImageCache sharedInstance] removeImageWithKey:self.identifier];
    if (self.msg.uploadedUrl) [[FlyImageCache sharedInstance] removeImageWithKey:self.msg.uploadedUrl];
    [[NSFileManager defaultManager] removeItemAtPath:[self pathOfArchive] error:nil];
    [self completeWithKey:nil];
}



#pragma mark -- process
-(void)completeWithKey:(NSString*)completeKey{
    NSLog(@"complete with key %@ self.identifier  %@",completeKey,self.identifier);
    if (completeKey) {
        self.msg.uploadedUrl = completeKey;
        [self changeMsgKey:self.identifier newKey:completeKey];
        [self saveArchive];
    }
    [self.port invalidate];
    [self.loop removePort:self.port forMode:NSDefaultRunLoopMode];
    self.port = nil;
    CFRunLoopStop(self.loop.getCFRunLoop);
    self.loop = nil;
    self.thread = nil;
    self.operation = nil;
}
-(void)convert:(void(^)(NSData* newMsg))complete {
    NSLog(@"convert begain %@",self.identifier);
    if (self.cachePathImage) {
        if (complete) complete([NSData dataWithContentsOfFile:self.cachePathImage]);
        return;
    }
    if (!self.msg.asset && self.msg.image) {
        NSData* data = self.msg.image.yy_imageDataRepresentation;
        [self save:data];
        if (complete) complete(data);
        return;
    }
    if ([[self.msg.asset valueForKey:@"filename"] hasSuffix:@"GIF"] || self.msg.isSelectOriginalPhoto){
        [[TZImageManager manager] getOriginalPhotoDataWithAsset:self.msg.asset completion:^(NSData *data, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            [self save:data];
//            if (self.thread) [self performSelector:@selector(save:) onThread:self.thread withObject:data waitUntilDone:NO];else [self save:data];
            if (complete) complete(data);
        }];
        return;
    }
    if(self.msg.asset){
        [[TZImageManager manager] getPhotoWithAsset:self.msg.asset photoWidth:1024 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            if (isDegraded) return;
            NSData* data = UIImageJPEGRepresentation(photo, 0.7);
            [self save:data];
//            if (self.thread) [self performSelector:@selector(save:) onThread:self.thread withObject:data waitUntilDone:NO];else [self save:data];
            if (complete) complete(data);
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

-(id<XYOperateProtocol>)processData:(NSData*)imageData complete:(void(^)(NSString* completeKey))complete {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        complete(@"http://www.baidu.com");
    });
    return nil;
}

-(void)dealloc{
    NSLog(@"dealloc current thread %@",[NSThread currentThread]);
}

#pragma mark -- pathes
-(NSString*)imagePath:(NSString*)name{
    return [[NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject] stringByAppendingFormat:@"/flyImage/files/%@",name];
}
+(NSString*)cachePath{
    NSString* path = [[NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject] stringByAppendingString:@"/imageuploader"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
+(NSString*)pathOfGroup:(NSString*)group{
    NSString* path = [[NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject] stringByAppendingFormat:@"/imageuploader/%@",group];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    return path;
}
-(NSString*)pathOfArchive{
    return [[ImageUploader pathOfGroup:self.group] stringByAppendingFormat:@"/%@.archive",[self.identifier stringByReplacingOccurrencesOfString:@"." withString:@""]];
}
-(NSString *)identifier{
    return self.msg.identifier;
}
-(NSString *)uploadedUrl{
    return self.msg.uploadedUrl;
}
@end
