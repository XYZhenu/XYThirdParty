//
//  XYScrollChartView.h
//  XYThirdParty
//
//  Created by Xie Yan, (Yan.Xie@partner.bmw.com) on 2017/7/19.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYScrollChartView : UIView
-(instancetype)initWithFrame:(CGRect)frame cellHeight:(CGFloat)cellheight cellWidth:(CGFloat)cellwidth topHeight:(CGFloat)topheight leftWidth:(CGFloat)leftWidth topNum:(NSInteger)topNum leftNum:(NSInteger)leftNum;


-(void)addTagContent:(id)content;
-(void)resetTag;

-(void)block_getFrame:(CGRect(^)(CGFloat cellWidth,CGFloat cellHeight,CGFloat totalWidth,CGFloat totalHeight,id content))getFrame 
       buildLeftLabel:(void(^)(UIView* view,NSInteger index))buildLeftLabel 
        buildTopLabel:(void(^)(UIView* view,NSInteger index))buildTopLabel 
             buildTag:(void(^)(UIView* view,id content))buildTag 
             clickTag:(void(^)(UIView* view,id content))clickTag
            buildLeft:(UIView*(^)(CGRect frame))buildLeft 
             buildTop:(UIView*(^)(CGRect frame))buildTop;
@end
