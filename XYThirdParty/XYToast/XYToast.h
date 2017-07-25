//
//  XYToast.h
//
//  Copyright (c) 2014年 itcast. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DEFAULT_DISPLAY_DURATION 2.0f


@interface XYToast : UIView {
    NSString *text;
//    UIButton *contentView;
    CGFloat  duration;
}
@property(nonatomic,strong)UIButton *contentView;
@property (nonatomic , strong)UILabel *textLabel ;
@property (nonatomic,strong)UIImageView * imageView;
- (void)hideAnimation;
- (void)dismissToast;
- (void)setDuration:(CGFloat) duration_;
- (void)show;
+ (XYToast*)showWithText:(NSString *) text_;
+ (XYToast*)showWithText:(NSString *) text_
            duration:(CGFloat)duration_;

+ (XYToast*)showWithText:(NSString *)text_  inView:(UIView*)view;


+ (XYToast*)showWithText:(NSString *)text_
                   inView:(UIView*)view
                 duration:(CGFloat)duration_;


+ (XYToast*)showWithText:(NSString *) text_
           topOffset:(CGFloat) topOffset_;
+ (XYToast*)showWithText:(NSString *) text_
           topOffset:(CGFloat) topOffset
            duration:(CGFloat) duration_;

+ (XYToast*)showWithText:(NSString *) text_
        bottomOffset:(CGFloat) bottomOffset_;
+ (XYToast*)showWithText:(NSString *) text_
        bottomOffset:(CGFloat) bottomOffset_
            duration:(CGFloat) duration_;

@end
