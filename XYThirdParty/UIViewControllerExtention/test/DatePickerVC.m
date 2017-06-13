//
//  DatePickerVC.m
//  XYCategories
//
//  Created by xieyan on 2017/6/4.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "DatePickerVC.h"
#import "UIViewController+DatePicker.h"

@interface DatePickerVC ()

@end

@implementation DatePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}
- (IBAction)pickTime:(id)sender {
    [self pickeDateType:XYDatePickerTypeTime start:nil end:nil formate:nil callBack:^(NSString * _Nonnull dateString, NSDate * _Nonnull date) {

    }];
}

@end
