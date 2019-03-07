//
//  UIViewController+ImagePicker.m
//  XYCategories
//
//  Created by xieyan on 2017/6/4.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "UIViewController+ImagePicker.h"
#import <TZImagePickerController/TZImagePickerController.h>

@implementation UIViewController (XYImagePicker)

- (UINavigationController*)pickeImagesNum:(NSInteger)num callback:(void(^)(NSArray<UIImage *> *photos, NSArray *assets,NSArray<NSDictionary *> *infos))callback{
    if (num < 1) {num = 1;};
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:nil];
    imagePickerVc.minImagesCount = 1;
    imagePickerVc.maxImagesCount = num;
    imagePickerVc.allowCameraLocation = NO;
    imagePickerVc.allowTakeVideo = NO;
    [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos){
        callback(photos,assets,infos);
    }];
    [imagePickerVc.navigationBar setBackgroundImage:[self xy_default_picker_image] forBarMetrics:(UIBarMetricsDefault)];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    return imagePickerVc;
}
- (UINavigationController*)pickeImageWithCallback:(void(^)(UIImage *photos, id assets))callback crop:(BOOL)crop{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isOrigin){
        callback(photos.firstObject,assets.firstObject);
    }];
    [imagePickerVc.navigationBar setBackgroundImage:[self xy_default_picker_image] forBarMetrics:(UIBarMetricsDefault)];
    imagePickerVc.allowCrop = crop;
    imagePickerVc.allowCameraLocation = NO;
    imagePickerVc.allowTakeVideo = NO;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    return imagePickerVc;
}
- (UINavigationController*)previewSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:selectedAssets selectedPhotos:selectedPhotos index:index];
    imagePickerVc.allowCameraLocation = NO;
    imagePickerVc.allowTakeVideo = NO;
    [imagePickerVc.navigationBar setBackgroundImage:[self xy_default_picker_image] forBarMetrics:(UIBarMetricsDefault)];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    return imagePickerVc;
}
- (UIImage *)xy_default_picker_image
{
    UIColor* color = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1];
    CGSize size = CGSizeMake(1, 1);
    if (color == nil) {
        return nil;
    }
    CGRect rect=CGRectMake(0.0f, 0.0f, size.width, size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}
@end
