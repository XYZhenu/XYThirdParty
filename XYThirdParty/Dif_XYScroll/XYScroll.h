//
//  XYScroll.h
//  XYCategories
//
//  Created by xieyan on 2017/6/5.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAPageControl.h"
NS_ASSUME_NONNULL_BEGIN;
IB_DESIGNABLE
@interface XYScroll : UIScrollView

-(void)prepare;//继承重写用

@property(nonatomic,assign)IBInspectable BOOL enableInfiniteScroll;//可以循环滚动默认开启

@property(nonatomic,strong,nullable)NSArray* messageArray;//设置内容
@property(nonatomic,assign)NSInteger currentPage;

@property(nonatomic,assign)IBInspectable CGFloat scrollInterval;//滚动间隔时间  >1s
@property(nonatomic,assign)IBInspectable CGFloat animateInterval;//动画时间  >0.1s  <1s
@property(nonatomic,assign)IBInspectable BOOL enableTimer;//默认关闭


@property(nonatomic,assign)IBInspectable BOOL enableIndicator;//指示器，默认不显示
@property(nonatomic,strong)TAPageControl* pageControl;


@property(nonatomic,strong,nullable)void(^layOut)(UIView*theView);

+(instancetype)new;

/**
 *  添加处理block
 *  ——————————————————都可以传空————————————————

 ————————为兼容代码和自动布局，界面frame另外设置，Scroll会通过block：layout自动适配————————

 *  @param messageSet 设置UI内容
 *  @param callBack 处理点击事件
 *  @param createUI   创建UI
 *  @param layOut   处理控件layout  使用frame
 *
 *  @return 为了代码创建方便，返回自身；      [[XYZScroll new] block_callBack:nil layOut:nil messgaeSet:nil];


 ------该函数设计只能调用一次，多次调用会覆盖前一次，设置messageArray会自动调用-------
 */
-(instancetype)set_createUI:(nullable void(^)(UIView* theView))createUI
                  layOut:(nullable void(^)(UIView* theView))layOut
           indicatorRect:(nullable CGRect(^)(CGRect bound))indicatorRect
                callBack:(nullable void(^)(NSInteger index,UIView* theView,id message))callBack
              messgaeSet:(nullable void(^)(NSInteger index,UIView* theView,id message))messageSet;

@end
NS_ASSUME_NONNULL_END;
