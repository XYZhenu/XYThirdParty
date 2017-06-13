//
//  UIViewController+DatePicker.h
//  JinXing
//
//  Created by xieyan on 2016/10/25.
//  Copyright © 2016年 JinXing. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN;
typedef  NS_ENUM(NSInteger, XYDatePickerType){
    XYDatePickerTypeTime,
    XYDatePickerTypeDate,
    XYDatePickerTypeDateTime,
    //    XYImagePickerType,
};
@interface UIViewController (DatePicker)
-(void)pickeDateType:(XYDatePickerType)type
              start:(nullable id)startTime
                end:(nullable id)endTime
            formate:(nullable NSString*)formate
           callBack:(void(^)(NSString* dateString,NSDate* date))callBack;
@end
NS_ASSUME_NONNULL_END;
