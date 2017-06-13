//
//  XYSegment.h
//  XYCategories
//
//  Created by xieyan on 2017/6/5.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN;
IB_DESIGNABLE
@interface XYSegment : UIView
@property(nonatomic,assign)IBInspectable NSInteger selectedIndex;

+(instancetype)new;

-(instancetype)set_Num:(NSInteger)number
              createUI:(void(^)(UIView* theView,NSInteger index))createUI
                layOut:(nullable void(^)(UIView* theView,NSInteger index))layOut
           selectState:(nullable void(^)(UIView* theView,BOOL selected))selectState
              callBack:(nullable void(^)(NSInteger index))callBack;

-(void)selectedIndexWithCallBack:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END;
