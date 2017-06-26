//
//  ImageUploader.h
//  XYThirdParty
//
//  Created by xyzhenu on 2017/6/26.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XYRichTextImage;
@interface ImageUploader : NSObject <NSCoding>
@property (nonatomic,strong)NSString* group;
@property (nonatomic,strong)NSString* identifier;

-(void)start;
-(void)suspend;
-(void)cancel;

@property (nonatomic,strong)XYRichTextImage* msg;

@property (nonatomic,strong)NSString* cachePathImage;

-(void)save;
@end
