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
- (void)pickeImagesWithCallback:(void(^)(NSArray<UIImage *> *photos, NSArray *assets,NSArray<NSDictionary *> *infos))callback {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:nil];
    imagePickerVc.minImagesCount = 1;
    [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos){
        callback(photos,assets,infos);
    }];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)pickeImageWithCallback:(void(^)(UIImage *photos, id assets))callback crop:(BOOL)crop{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:1 delegate:nil];
    [imagePickerVc setDidFinishPickingPhotosHandle:^(NSArray<UIImage *> *photos, NSArray *assets, BOOL isOrigin){
        callback(photos.firstObject,assets.firstObject);
    }];
    imagePickerVc.allowCrop = crop;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
- (void)previewSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:selectedAssets selectedPhotos:selectedPhotos index:index];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
}
@end
