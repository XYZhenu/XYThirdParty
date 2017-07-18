//
//  UIViewController+ImagePicker.h
//  XYCategories
//
//  Created by xieyan on 2017/6/4.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN;
@interface UIViewController (XYImagePicker)
- (void)pickeImagesWithCallback:(void(^)(NSArray<UIImage *> *photos, NSArray *assets,NSArray<NSDictionary *> *infos))callback;
- (void)pickeImageWithCallback:(void(^)(UIImage *photos, id assets))callback  crop:(BOOL)crop;
- (void)previewSelectedAssets:(NSMutableArray *)selectedAssets selectedPhotos:(NSMutableArray *)selectedPhotos index:(NSInteger)index;
@end
NS_ASSUME_NONNULL_END;
