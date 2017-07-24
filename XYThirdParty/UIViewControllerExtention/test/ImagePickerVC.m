//
//  ImagePickerVC.m
//  XYCategories
//
//  Created by xieyan on 2017/6/4.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "ImagePickerVC.h"
#import "UIViewController+ImagePicker.h"

@interface ImagePickerVC ()

@end

@implementation ImagePickerVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)pickerClick:(id)sender {
    [self pickeImagesWithCallback:^(NSArray<UIImage *> * _Nonnull photos, NSArray * _Nonnull assets, NSArray* infos) {

    }];
}
- (IBAction)pickOneClick:(id)sender {
    [self pickeImageWithCallback:^(UIImage * _Nonnull photos, id  _Nonnull assets) {
        
    } crop:NO];
}

@end
