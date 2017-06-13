//
//  UIViewController+DatePicker.m
//  JinXing
//
//  Created by xieyan on 2016/10/25.
//  Copyright © 2016年 JinXing. All rights reserved.
//

#import "UIViewController+DatePicker.h"
#import <objc/runtime.h>
#define XYPickerSET(_K_,_O_) objc_setAssociatedObject(self, &_K_, _O_, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
#define XYPickerGET(_K_) objc_getAssociatedObject(self, &_K_)
@implementation UIViewController (DatePicker)
static char datePicker;
static char datePicker_callBack;
static char datePicker_container;
static char datePicker_Formater;
-(UIView*)xyDatePickerContainer{
    UIView* xyDatePickerContainer = XYPickerGET(datePicker_container);
    if (!xyDatePickerContainer) {
        xyDatePickerContainer = [[UIView alloc]init];
        xyDatePickerContainer.backgroundColor = [UIColor whiteColor];
        [self.view addSubview:xyDatePickerContainer];
        UIButton * leftBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [leftBtn addTarget:self action:@selector(xyDatePickerCancelClick) forControlEvents:UIControlEventTouchUpInside];
        [leftBtn setTitle:@"取消" forState:UIControlStateNormal];
        [leftBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        [xyDatePickerContainer addSubview:leftBtn];
        
        
        UIButton * rightBtn =[UIButton buttonWithType:UIButtonTypeCustom];
        [rightBtn setTitle:@"确定" forState:UIControlStateNormal];
        [rightBtn addTarget:self action:@selector(xyDatePickerConfirmClick) forControlEvents:UIControlEventTouchUpInside];
        [rightBtn setTitleColor:[UIColor colorWithRed:51/255.0 green:51/255.0 blue:51/255.0 alpha:1] forState:UIControlStateNormal];
        [xyDatePickerContainer addSubview:rightBtn];

        xyDatePickerContainer.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:@[
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:xyDatePickerContainer attribute:NSLayoutAttributeLeft multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:xyDatePickerContainer attribute:NSLayoutAttributeRight multiplier:1 constant:0],
        [NSLayoutConstraint constraintWithItem:self.view attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:xyDatePickerContainer attribute:NSLayoutAttributeBottom multiplier:1 constant:0]
                                                 ]];
        [xyDatePickerContainer addConstraint:[NSLayoutConstraint constraintWithItem:xyDatePickerContainer attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:230]];

        leftBtn.translatesAutoresizingMaskIntoConstraints = NO;
        rightBtn.translatesAutoresizingMaskIntoConstraints = NO;
        [xyDatePickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-20-[leftBtn(==40)]->=0-[rightBtn(==40)]-20-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(leftBtn,rightBtn)]];
        [xyDatePickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0.5-[leftBtn(==30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(leftBtn)]];
        [xyDatePickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0.5-[rightBtn(==30)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(rightBtn)]];
        XYPickerSET(datePicker_container, xyDatePickerContainer);
        xyDatePickerContainer.hidden = YES;



        UIView* separator = [[UIView alloc] init];
        separator.backgroundColor = [UIColor colorWithRed:240/255.0 green:240/255.0 blue:240/255.0 alpha:1];
        [xyDatePickerContainer addSubview:separator];
        separator.translatesAutoresizingMaskIntoConstraints = NO;
        [xyDatePickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[separator(==0.5)]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];
        [xyDatePickerContainer addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[separator]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(separator)]];

    }
    return xyDatePickerContainer;
}

-(UIDatePicker*)xyDatePicker{
    UIDatePicker* _datePicker = XYPickerGET(datePicker);
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.translatesAutoresizingMaskIntoConstraints = NO;
        [[self xyDatePickerContainer] addSubview:_datePicker];
        [[self xyDatePickerContainer] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_datePicker]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_datePicker)]];
        [[self xyDatePickerContainer] addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-30-[_datePicker]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_datePicker)]];

        XYPickerSET(datePicker, _datePicker);
    }
    return _datePicker;
}


-(void)pickeDateType:(XYDatePickerType)type start:(id)startTime end:(id)endTime formate:(NSString*)formate callBack:(void(^)(NSString* dateString,NSDate* date))callBack{
    
    [self xyDatePickerContainer].hidden = YES;
    [self xyDatePicker].date = [NSDate date];
    [self xyDatePicker].minimumDate = nil;
    [self xyDatePicker].maximumDate = nil;
    
    if (!callBack) {
        return;
    }
    
    switch (type) {

        case XYDatePickerTypeTime:
            [self xyDatePicker].datePickerMode = UIDatePickerModeTime;
            
            break;
        case XYDatePickerTypeDateTime:
            [self xyDatePicker].datePickerMode = UIDatePickerModeDateAndTime;
            
            break;
        default:
            [self xyDatePicker].datePickerMode = UIDatePickerModeDate;
            break;
    }
    
    NSDateFormatter * dateFormatter =[[NSDateFormatter alloc] init];
    if (!formate || formate.length == 0) {
        dateFormatter.dateFormat = @"yyyy-MM-dd";
    }
    XYPickerSET(datePicker_Formater, dateFormatter);
    

    
    if ([startTime isKindOfClass:[NSDate class]]) {
        [self xyDatePicker].minimumDate = startTime;
    }else if ([startTime isKindOfClass:[NSString class]]){
        [self xyDatePicker].minimumDate = [dateFormatter dateFromString:startTime];
    }else if (startTime == nil){
        [self xyDatePicker].minimumDate = nil;
    }else{
        return;
    }
    
    if ([endTime isKindOfClass:[NSDate class]]) {
        [self xyDatePicker].maximumDate = startTime;
    }else if ([endTime isKindOfClass:[NSString class]]){
        [self xyDatePicker].maximumDate = [dateFormatter dateFromString:startTime];
    }else if (endTime == nil){
        [self xyDatePicker].maximumDate = nil;
    }else{
        return;
    }
    
    [self xyDatePickerContainer].hidden = NO;
    [self.view bringSubviewToFront:[self xyDatePickerContainer]];
    
    XYPickerSET(datePicker_callBack, callBack);
    [self pickerAnimateShow:YES];
}

- (void)pickerAnimateShow:(BOOL)show {
    UIView* picker = [self xyDatePickerContainer];
    [self.view bringSubviewToFront:picker];
    picker.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, (show ? 230 : 0));
    [UIView animateWithDuration:0.3 animations:^{
        picker.transform = CGAffineTransformTranslate(CGAffineTransformIdentity, 0, (show ? 0 : 230));
    } completion:^(BOOL finished) {
        picker.hidden = !show;
    }];
}

-(void)xyDatePickerCancelClick{
    ((void(^)(NSString*,NSDate*))XYPickerGET(datePicker_callBack))(nil,nil);
    XYPickerSET(datePicker_callBack, nil);
    [self pickerAnimateShow:NO];
}
-(void)xyDatePickerConfirmClick{
    NSDate* date = [self xyDatePicker].date;
    NSString* dateString = [((NSDateFormatter*)XYPickerGET(datePicker_Formater)) stringFromDate:date];
    ((void(^)(NSString*,NSDate*))XYPickerGET(datePicker_callBack))(dateString,date);
    XYPickerSET(datePicker_Formater, nil);
    XYPickerSET(datePicker_callBack, nil);
    [self pickerAnimateShow:NO];
}

@end
