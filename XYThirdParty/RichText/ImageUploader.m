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

@implementation ImageUploader
- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        self.cachePath = [coder decodeObjectForKey:@"cachepath"];
        self.msg = [coder decodeObjectOfClass:[XYRichTextImage class] forKey:@"msg"];
    }
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.cachePath forKey:@"cachepath"];
    [aCoder encodeObject:self.msg forKey:@"msg"];
}
-(void)save {
    [NSKeyedArchiver archiveRootObject:self toFile:[self cachePath]];
}
+(void)instanceOfGroup:(NSString*)group{
    [NSKeyedUnarchiver unarchiveObjectWithFile:<#(nonnull NSString *)#>]
}

-(void)start {
    [self convert:^(NSData* imageData) {
        [self processData:imageData complete:^(NSString *completeKey) {
            [self changeMsgKey:self.msg.identifier newKey:completeKey];
        }];
    }];
}
-(void)suspend {
    
}
-(void)cancel {
    
}

-(void)convert:(void(^)(NSData* newMsg))complete {
    if (self.cachePath) {
        complete([NSData dataWithContentsOfFile:self.cachePath]);
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
            [self save:data];
            complete(data);
        }];
        return;
    }
    if(self.msg.asset){
        [[TZImageManager manager] getPhotoWithAsset:self.msg.asset photoWidth:1024 completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
            NSData* data = UIImageJPEGRepresentation(photo, 0.7);
            [self save:data];
            complete(data);
        }];
    }
}
-(void)save:(NSData*)imageData{
    self.cachePath = [self pathOfImage:self.msg];
    [imageData writeToFile:self.cachePath atomically:YES];
    [[FlyImageCache sharedInstance] addImageWithKey:self.msg.identifier filename:self.cachePath completed:nil];
    [[FlyImageCache sharedInstance] protectFileWithKey:self.msg.identifier];
}


+(NSString*)cachePath{
    return [[NSSearchPathForDirectoriesInDomains (NSCachesDirectory , NSUserDomainMask , YES) firstObject] stringByAppendingString:@"/imageuploader"];
}
+(NSString*)pathOfGroup:(NSString*)group{
    return [[self cachePath] stringByAppendingFormat:@"/%@",group];
}
-(NSString*)pathOfImage:(XYRichTextImage*)image{
    if (image.asset) {
        return [[ImageUploader pathOfGroup:self.group] stringByAppendingFormat:@"/%@",self.msg.fileName];
    }else{
        return [[ImageUploader pathOfGroup:self.group] stringByAppendingFormat:@"/%@",self.msg.identifier];
    }
}
+(NSString*)cachePath{
    return [];
}

-(void)changeMsgKey:(NSString*)oldKey newKey:(NSString*)newKey {
    [[FlyImageCache sharedInstance] unProtectFileWithKey:oldKey];
    [[FlyImageCache sharedInstance] changeImageKey:oldKey newKey:newKey];
}

-(void)processData:(NSData*)imageData complete:(void(^)(NSString* completeKey))complete {
    
}
@end
