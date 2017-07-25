//
//  XYLoadingPage.h
//  XYCategories
//
//  Created by xieyan on 2017/6/10.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XYLoadingPage : UIViewController
-(void)finish;
-(void)indexClick:(int)index;
-(void)loadReq:(void(^)(NSArray<NSString*>* images))complete;

-(void)imageView:(UIImageView*)imageview loadImage:(NSString*)url placeHolder:(UIImage*)image;
@end
