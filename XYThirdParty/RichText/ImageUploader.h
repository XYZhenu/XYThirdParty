//
//  ImageUploader.h
//  XYThirdParty
//
//  Created by xyzhenu on 2017/6/26.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import <Foundation/Foundation.h>
@class XYRichTextImage;
@interface ImageUploader : NSOperation <NSCoding>
@property (nonatomic,strong)NSString* group;
@property (nonatomic,strong)NSString* identifier;


@property (nonatomic,strong)XYRichTextImage* msg;

-(void)save;
@end
