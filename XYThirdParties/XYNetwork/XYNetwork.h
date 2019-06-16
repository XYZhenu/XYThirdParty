//
//  XYNetwork.h
//  shell
//
//  Created by xyzhenu on 2017/3/21.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AFNetworking;
NS_ASSUME_NONNULL_BEGIN;
typedef NS_ENUM(NSUInteger, XYSerializerType) {
    XYSerializerType_Origin,
    XYSerializerType_Json,
    XYSerializerType_Xml,
};
@interface XYNetwork : AFHTTPSessionManager
+(instancetype)instance;
-(void)initSetting;//subclass using
-(void)setAcceptableContentTypes:(NSSet <NSString *> *)acceptableContentTypes for:(XYSerializerType)type;
-(NSURLSessionDataTask *)request:(NSMutableURLRequest *)request
                  serializerType:(XYSerializerType)type
                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                        complete:(nullable void (^)(NSURLResponse * response, id _Nullable responseObject, NSError * _Nullable error))complete
                       hudInView:(UIView* _Nullable)view;

@end
NS_ASSUME_NONNULL_END;
