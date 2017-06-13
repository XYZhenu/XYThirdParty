//
//  XYSlider.m
//  XYCategories
//
//  Created by xieyan on 2017/6/5.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "XYSlider.h"

@implementation XYSlider
- (CGRect)thumbRectForBounds:(CGRect)bounds trackRect:(CGRect)rect value:(float)value
{
    //y轴方向改变手势范围
    rect.origin.y = rect.origin.y - 10;
    rect.size.height = rect.size.height + 20;
    rect.origin.x = rect.origin.x - 10;
    rect.size.width = rect.size.width + 20;
    return CGRectInset ([super thumbRectForBounds:bounds trackRect:rect value:value], 10 ,10);
}
@end
