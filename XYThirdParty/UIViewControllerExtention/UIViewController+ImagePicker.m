//
//  UIViewController+ImagePicker.m
//  XYCategories
//
//  Created by xieyan on 2017/6/4.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "UIViewController+ImagePicker.h"
#import <TZImagePickerController/TZImagePickerController.h>
#import <TZImagePickerController/TZAssetCell.h>
#import "XYThirdParty/XYToast.h"
#import "objc/runtime.h"
@interface TZAssetModel (xyselect)
@property (nonatomic, weak) TZAssetCell* cell;
-(void)serSelecte:(BOOL)select;
@end
@implementation TZAssetModel (xyselect)
static char selectedassetkey;
-(TZAssetCell*)cell {
    return objc_getAssociatedObject(self, &selectedassetkey);
}
- (void)setCell:(TZAssetCell*)cell{
    objc_setAssociatedObject(self, &selectedassetkey, cell, OBJC_ASSOCIATION_ASSIGN);
}
-(void)serSelecte:(BOOL)select{
    self.isSelected = select;
    self.cell.selectPhotoButton.selected = select;
}
@end

@interface UIViewController () <TZImagePickerControllerDelegate>
@end
@implementation UIViewController (XYImagePicker)

- (UINavigationController*)pickeImagesNum:(NSInteger)num callback:(void(^)(NSArray<UIImage *> *photos, NSArray *assets,NSArray<NSDictionary *> *infos))callback{
    if (num < 1) {num = 1;};
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:nil];
    imagePickerVc.minImagesCount = 1;
    imagePickerVc.maxImagesCount = num;
    imagePickerVc.allowCameraLocation = NO;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos){
        callback(photos,assets,infos);
    }];
    [imagePickerVc.navigationBar setBackgroundImage:[self xy_default_picker_image] forBarMetrics:(UIBarMetricsDefault)];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    return imagePickerVc;
}
- (UINavigationController*)pickeImagesAndVideoNum:(NSInteger)num callback:(void(^)(NSArray<UIImage *> *photos, NSArray*assets,NSArray<NSDictionary *> *infos))callback{
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:6 delegate:self];
    imagePickerVc.minImagesCount = 1;
    if (num == 0) {
        imagePickerVc.allowPickingImage = NO;
    }else{
        if (num < 1) {num = 1;};
        imagePickerVc.maxImagesCount = num;
    };
    imagePickerVc.allowTakeVideo = YES;
    imagePickerVc.allowCameraLocation = NO;
    imagePickerVc.maxCropVideoDuration = 30;
    imagePickerVc.videoMaximumDuration = 30;
    imagePickerVc.allowEditVideo = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    imagePickerVc.showPhotoCannotSelectLayer = YES;
    
    [imagePickerVc setDidFinishPickingPhotosWithInfosHandle:^(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto,NSArray<NSDictionary *> *infos){
        callback(photos,assets,infos);
    }];
    [imagePickerVc setDidFinishPickingAndEditingVideoHandle:^(UIImage *coverImage, NSString *outputPath, NSString *errorMsg) {
        
    }];
    [imagePickerVc setDidFinishPickingVideoHandle:^(UIImage *coverImage, PHAsset *asset) {
        callback(@[coverImage],@[asset],@[@{}]);
    }];
    [imagePickerVc setAssetCellDidSetModelBlock:^(TZAssetCell *cell, UIImageView *imageView, UIImageView *selectImageView, UILabel *indexLabel, UIView *bottomView, UILabel *timeLength, UIImageView *videoImgView) {
        cell.model.cell = cell;
    }];
    [imagePickerVc.navigationBar setBackgroundImage:[self xy_default_picker_image] forBarMetrics:(UIBarMetricsDefault)];
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    return imagePickerVc;
}
- (void)imagePickerController:(TZImagePickerController *)picker didSelectAsset:(PHAsset *)asset photo:(UIImage *)photo isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    NSArray* modelscopy = picker.selectedModels.copy;
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        for (TZAssetModel* model in modelscopy) {
            if (![model.asset.localIdentifier isEqualToString: asset.localIdentifier]) {
                [NSOperationQueue.currentQueue addOperationWithBlock:^{
                    [model.cell performSelector:@selector(selectPhotoButtonClick:) withObject:model.cell.selectPhotoButton];
                }];
            }
        }
    }else if (asset.mediaType == PHAssetMediaTypeImage) {
        
        for (TZAssetModel* model in modelscopy) {
            if (model.type == TZAssetModelMediaTypeVideo) {
                [NSOperationQueue.currentQueue addOperationWithBlock:^{
                    [model.cell performSelector:@selector(selectPhotoButtonClick:) withObject:model.cell.selectPhotoButton];
                }];
            }
        }
    }
//    NSLog(@"%@",picker.selectedModels);
}
- (void)imagePickerController:(TZImagePickerController *)picker didDeselectAsset:(PHAsset *)asset photo:(UIImage *)photo isSelectOriginalPhoto:(BOOL)isSelectOriginalPhoto {
    
}

- (BOOL)isAssetCanBeSelected:(PHAsset *)asset {
//    TZImagePickerController *imagePickerVc = (TZImagePickerController *)self.presentedViewController;
//    NSArray* allvalue = imagePickerVc.selectedAssets;
//    if (allvalue.count > 0) {
//        __block BOOL isVideoMode = NO;
//        [allvalue enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//            if(obj.mediaType == PHAssetMediaTypeVideo){
//                isVideoMode = YES;
//                *stop = YES;
//            }
//        }];
//        if (isVideoMode) {
//            return false;
//        } else if (asset.mediaType == PHAssetMediaTypeVideo) {
//            return false;
//        }
//    }
    if (asset.mediaType != PHAssetMediaTypeImage && asset.mediaType != PHAssetMediaTypeVideo) {
        return false;
    }
    if (asset.mediaType == PHAssetMediaTypeVideo && asset.duration > 30) {
        [XYToast showWithText:@"请选择 30 秒以内的视频"];
        return false;
    }
    return true;
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
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
    [self presentViewController:imagePickerVc animated:YES completion:nil];
    return imagePickerVc;
}
- (UINavigationController*)previewSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index {
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithSelectedAssets:selectedAssets selectedPhotos:selectedPhotos index:index];
    imagePickerVc.allowCameraLocation = NO;
    imagePickerVc.allowTakeVideo = NO;
    imagePickerVc.allowPickingVideo = NO;
    imagePickerVc.allowPickingMultipleVideo = NO;
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

