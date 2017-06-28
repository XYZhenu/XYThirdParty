//
//  ImageUploader.h
//  XYThirdParty
//
//  Created by xyzhenu on 2017/6/26.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import <Foundation/Foundation.h>
@protocol XYOperateProtocol <NSObject>
-(void)cancel;
@end
@class ImageUploader;
@protocol XYOperateDelegate <NSObject>
-(void)uploaderComplete:(ImageUploader*)uploader error:(BOOL)error;
@end
@class XYRichTextImage;
@interface ImageUploader : NSOperation <NSCoding,XYOperateProtocol>
@property (nonatomic,strong)NSString* group;
@property (nonatomic,strong)NSString* identifier;

@property (nonatomic,strong)XYRichTextImage* msg;

@property (nonatomic,weak)id<XYOperateDelegate>operDelegate;
-(void)save;

+(NSString*)cachePath;
+(NSArray<ImageUploader*>*)instancesOfGroup:(NSString*)group;
@end
