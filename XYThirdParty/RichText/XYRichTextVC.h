//
//  XYRichTextVC.h
//  RichText
//
//  Created by xieyan on 2017/6/21.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger,XYRichTextImageSaveType) {
    XYRichTextImageSaveTypeOnInsert = 1<<1,
    XYRichTextImageSaveTypeOnSaveClick = 1<<2,//default
};
@interface XYRichTextImage : NSObject
@property (nonatomic,strong,nullable)PHAsset* asset;
@property (nonatomic,strong,nullable)UIImage* image;
@property (nonatomic,strong,nullable)NSDictionary* info;
@property (nonatomic,strong,nullable)NSURL* url;
@property (nonatomic,strong,nullable)NSString* identifier;
@property (nonatomic,assign)BOOL isSelectOriginalPhoto;//default no
@end
@interface XYRichTextVC : UIViewController
@property (nonatomic,strong)NSString* picSymbolPrefix;//default [
@property (nonatomic,strong)NSString* picSymbolSuffix;//default ]
- (void)pickImage:(void(^)(NSArray<PHAsset*>* assets, NSArray<UIImage*>*images,NSArray<NSDictionary *> *infos,BOOL isSelectOriginalPhoto))complete;
@property(nonatomic,assign)XYRichTextImageSaveType saveType;
- (void)onSaveWithText:(NSString*)content images:(NSDictionary<NSString*,XYRichTextImage*>*)images complete:(BOOL)complete;
@end
NS_ASSUME_NONNULL_END
