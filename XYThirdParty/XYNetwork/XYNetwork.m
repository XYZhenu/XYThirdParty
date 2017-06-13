//
//  XYNetwork.m
//  shell
//
//  Created by xyzhenu on 2017/3/21.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "XYNetwork.h"
#import <MBProgressHUD/MBProgressHUD.h>

@interface XYResponSerializer : AFHTTPResponseSerializer
@property (strong, nonatomic) NSMutableDictionary *serializerTypeMap;
@property (strong, nonatomic) AFJSONResponseSerializer *jsonSerializer;
@end

@implementation XYResponSerializer
-(NSMutableDictionary *)serializerTypeMap {
    if (!_serializerTypeMap) { _serializerTypeMap = @[].mutableCopy; }
    return _serializerTypeMap;
}

-(AFJSONResponseSerializer *)jsonSerializer{
    if (!_jsonSerializer) {
        _jsonSerializer = [AFJSONResponseSerializer serializer];
    }
    return _jsonSerializer;
}

-(id)responseObjectForResponse:(NSURLResponse *)response
                          data:(NSData *)data
                         error:(NSError *__autoreleasing  _Nullable *)error
{
    XYSerializerType type = XYSerializerType_Json;
    if (self.serializerTypeMap[response.URL.absoluteString]) {
        type = [self.serializerTypeMap[response.URL] integerValue];
    }
    switch (type) {
        case XYSerializerType_Json:
            return [self.jsonSerializer responseObjectForResponse:response data:data error:error];
            break;
        default:
            return [super responseObjectForResponse:response data:data error:error];
            break;
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder { [super encodeWithCoder:aCoder]; }
- (instancetype)initWithCoder:(NSCoder *)coder { return [super initWithCoder:coder]; }
+ (BOOL)supportsSecureCoding { return [super supportsSecureCoding]; }
- (id)copyWithZone:(NSZone *)zone { return [super copyWithZone:zone]; }

@end

@interface XYNetwork ()
@property (strong, nonatomic) NSMutableDictionary *serializerTypeMap;
@end

@implementation XYNetwork
+(NSDictionary*)getCachedDic:(NSString*)cacheName{
    NSDictionary* dic = nil;
    if (cacheName) {
        NSString* cachepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@.json",cacheName]];
        dic = [NSDictionary dictionaryWithContentsOfFile:cachepath];
    }
    return dic;
}
+(void)setCachedDic:(NSDictionary*)dic name:(NSString*)cacheName{
    if (!dic || !cacheName) {
        return;
    }
    NSString* cachepath = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@.json",cacheName]];
    [dic writeToFile:cachepath atomically:YES];
}


+(instancetype)instance{
    static XYNetwork* manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [self manager];
        manager.requestSerializer = [AFHTTPRequestSerializer serializer];
        manager.responseSerializer = [XYResponSerializer serializer];
        manager.operationQueue.maxConcurrentOperationCount = 3;
        [manager initSetting];
    });
    return manager;
}
-(void)initSetting{}
-(void)setResponseSerializer:(AFHTTPResponseSerializer<AFURLResponseSerialization> *)responseSerializer {
    [super setResponseSerializer:responseSerializer];
    if ([responseSerializer isKindOfClass:[XYResponSerializer class]]) {
        self.serializerTypeMap = ((XYResponSerializer*)responseSerializer).serializerTypeMap;
    }
}

-(NSURLSessionDataTask *)request:(NSMutableURLRequest *)request
                  serializerType:(XYSerializerType)type
                  uploadProgress:(nullable void (^)(NSProgress *uploadProgress)) uploadProgressBlock
                downloadProgress:(nullable void (^)(NSProgress *downloadProgress)) downloadProgressBlock
                        complete:(nullable void (^)(NSURLResponse * __unused response, id responseObject, NSError *error))complete
                       hudInView:(UIView* _Nullable)view
{
    if (type != XYSerializerType_Json) {
        [self.serializerTypeMap setObject:@(type) forKey:request.URL.absoluteString];
    }
    if (view) {
        [MBProgressHUD showHUDAddedTo:view animated:YES];
    }
    NSURLSessionDataTask *dataTask = nil;
    dataTask = [self dataTaskWithRequest:request
                          uploadProgress:uploadProgressBlock
                        downloadProgress:downloadProgressBlock
                       completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                           if (complete)  complete(response,responseObject,error);
                           if (view) {
                               [MBProgressHUD hideHUDForView:view animated:YES];
                           }
                       }];
    [dataTask resume];
    return dataTask;
}

@end
