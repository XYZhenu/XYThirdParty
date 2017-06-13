//
//  XYLoadingPage.m
//  XYCategories
//
//  Created by xieyan on 2017/6/10.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "XYLoadingPage.h"
#import "XYThirdParty.h"
#import "XYScroll.h"
#import <MZTimerLabel/MZTimerLabel.h>
#import "../XYImageManager/UIImageView+ImageLoader.h"

@interface XYLoadingPage ()<MZTimerLabelDelegate>
@property (nonatomic, strong)XYScroll* scroll;

@end

@implementation XYLoadingPage
- (UIImage*)lanuchImage {
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString* viewOrientation = @"Portrait";
    NSString* launchImage = nil;
    NSArray* imageDic = [[NSBundle mainBundle] infoDictionary][@"UILaunchImages"];
    for (NSDictionary* dic in imageDic) {
        CGSize imageSize = CGSizeFromString(dic[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dic[@"UILaunchImageOrientation"]]) {
            launchImage = dic[@"UILaunchImageName"];
            break;
        }
    }
    if (launchImage) {
        NSString* path = [[NSBundle mainBundle] pathForResource:launchImage ofType:@"png"];
        return [[UIImage alloc] initWithContentsOfFile:path];
    }
    return nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    __weak typeof(self) weakself = self;
    self.scroll = [[XYScroll new] set_createUI:^(UIView * _Nonnull theView) {
        ImageCreate(100);
        image_100.contentMode = UIViewContentModeScaleToFill;
        image_100.image = [self lanuchImage];
        [theView addSubview:image_100];
    } layOut:^(UIView * _Nonnull theView) {
        Image(100).frame = theView.bounds;
    } indicatorRect:nil callBack:^(NSInteger index, UIView * _Nonnull theView, id  _Nonnull message) {
        [weakself indexClick:(int)index];
    } messgaeSet:^(NSInteger index, UIView * _Nonnull theView, id  _Nonnull message) {
        [Image(100) xy_load:message placeHolder:[self lanuchImage]];
    }];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.scroll];
    self.scroll.translatesAutoresizingMaskIntoConstraints = NO;
    UIView* scrollview = self.scroll;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scrollview)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[scrollview]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scrollview)]];

    self.scroll.scrollEnabled = NO;

    UIButton* button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
    [button addTarget:self action:@selector(finish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:[button(90)]-15-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[button(24)]-40-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(button)]];
    button.clipsToBounds = YES;
    button.layer.cornerRadius = 12;
    button.hidden = YES;

    MZTimerLabel* label = [[MZTimerLabel alloc] initWithTimerType:MZTimerLabelTypeTimer];
    [button addSubview:label];
    label.text = @"跳过";
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor whiteColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [button addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];

    label.delegate = self;
    [label setCountDownTime:5];
    label.hidden = YES;
    [self loadReq:^(NSArray<NSString *> *images) {
        if (images.count==0) {
            [weakself finish];
        }else{
            weakself.scroll.messageArray = images;
        }
    }];

}
-(NSString*)timerLabel:(MZTimerLabel*)timerLabel customTextToDisplayAtTime:(NSTimeInterval)time {
    if (((long)time) > 10 || ((long)time) <= 0) return @"跳过";
    if (time>4) time = 4;
    return [NSString stringWithFormat:@"跳过 %lds",(long)time+1];
}

-(void)timerLabel:(MZTimerLabel*)timerLabel countingTo:(NSTimeInterval)time timertype:(MZTimerLabelType)timerType{

}

-(void)timerLabel:(MZTimerLabel*)timerLabel finshedCountDownTimerWithTime:(NSTimeInterval)countTime {
    [self finish];
}

-(void)finish{}
-(void)indexClick:(int)index {}
-(void)loadReq:(void(^)(NSArray<NSString*>*))images {}
@end
