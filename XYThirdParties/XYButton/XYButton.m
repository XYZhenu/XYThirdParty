//
//  XYButton.m
//  XYCategories
//
//  Created by xieyan on 2017/6/5.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "XYButton.h"
@interface XYButton ()
@property(nonatomic,strong) void (^callBack) (BOOL isSelected,UIView* theView);
@property(nonatomic,strong) void (^layOut) (UIView* theView);
@property(nonatomic,strong) void (^touched) (BOOL isTouched,UIView* theView);
@property(nonatomic,strong) void (^messageSet) (BOOL isSelected,UIView* theView,NSDictionary* message);
@property(nonatomic,strong) void(^selectState)(BOOL isSelected,UIView* theView);
@end
@implementation XYButton

-(instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}
-(void)prepare{
    _isSelected = NO;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (self.selectState) {
        self.selectState(isSelected,self);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touched) {
        self.touched(YES,self);
    }
}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touched) {
        self.touched(NO,self);
    }
    if (self.callBack) {
        _isSelected = !_isSelected;
        self.callBack(_isSelected, self);
    }
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.touched) {
        self.touched(NO,self);
    }
}



-(void)layoutSubviews{
    [super layoutSubviews];
    if (self.layOut) {
        self.layOut(self);
    }
}
-(void)xyMessageSet:(NSDictionary*)message{
    if (self.messageSet) {
        self.messageSet(_isSelected,self,message);
    }
}

+(instancetype)new{
    return [[self alloc] init];
}
-(instancetype)set_customUI:(void(^)(UIView* theView))customUI
                     layOut:(void(^)(UIView* theView))layOut
                   callBack:(void(^)(BOOL isSelected,UIView* theView))callBack
                    touched:(void(^)(BOOL isTouched, UIView* theView))touched
                 messgaeSet:(void(^)(BOOL isSelected,UIView* theView,NSDictionary* message))messageSet{
    self.callBack = callBack;
    self.layOut = layOut;
    self.touched = touched;
    self.messageSet = messageSet;
    if (customUI) {
        customUI(self);
    }
    return self;
}
-(instancetype)set_customUI:(void(^)(UIView* theView))customUI
                     layOut:(void(^)(UIView* theView))layOut
                   callBack:(void(^)(BOOL isSelected,UIView* theView))callBack
                    touched:(void(^)(BOOL isTouched, UIView* theView))touched
                 messgaeSet:(void(^)(BOOL isSelected,UIView* theView,NSDictionary* message))messageSet
               selecteState:(void(^)(BOOL isSelected,UIView* theView))selectState{
    self.callBack = callBack;
    self.layOut = layOut;
    self.touched = touched;
    self.messageSet = messageSet;
    self.selectState = selectState;
    if (customUI) {
        customUI(self);
    }
    return self;
}

@end
