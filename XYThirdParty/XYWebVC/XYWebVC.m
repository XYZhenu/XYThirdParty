//
//  XYWebVC.m
//  XYCategories
//
//  Created by xyzhenu on 2017/6/8.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "XYWebVC.h"
#import "XYButton.h"
#import "XYNetwork.h"
#import "XYThirdParty.h"
#import "Log.h"
@interface XYWebVC ()<WKNavigationDelegate>
@property(nonatomic,strong)NSDictionary*parma;
@property(nonatomic,copy)NSString*url;
@property(nonatomic,strong)NSDictionary*parmaDic;
@property(nonatomic,strong)WKWebView*web;
@property(nonatomic,strong)UIView* progressView;
@property(nonnull,strong)NSArray* btnArray;
@property(nonatomic,strong)UIImage* returnImage;
@end

@implementation XYWebVC
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent=NO;
    
    if (@available(iOS 13.0, *)) {
        self.web.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    if (self.navigationController.viewControllers.firstObject == self) {
        self.tabBarController.tabBar.hidden=NO;
        self.tabBarController.tabBar.translucent=NO;
    }else{
        self.tabBarController.tabBar.hidden=YES;
        self.tabBarController.tabBar.translucent=YES;
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
}
- (void)addWebviewReturnButton:(id _Nullable)content {
    if (!self.navigationController || self.navigationController.viewControllers.firstObject == self) {
        return;
    }
    UIImage* image = nil;
    if ([content isKindOfClass:[NSString class]]) {
        image = [UIImage imageNamed:content];
    }else if ([content isKindOfClass:[UIImage class]]){
        image = content;
    }
    UIButton* btn = [UIButton buttonWithType:UIButtonTypeCustom];
    if (!image) {
        image = [UIImage imageNamed:@"return" inBundle:[NSBundle bundleForClass:[XYWebVC class]] compatibleWithTraitCollection:nil];
    }
    self.returnImage = image;
    [btn setImage:image forState:UIControlStateNormal];
    btn.frame = CGRectMake(0, 0, 40, 40);
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    //    btn.imageEdgeInsets = UIEdgeInsetsMake(0, -12, 0, 0);
    [btn addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationController.navigationBar.tintColor = [UIColor blackColor];
}
-(void)bindWebView:(WKWebView*)webView{
    _web = webView;
}
-(WKWebView *)web{
    if (!_web) {
        _web = [[WKWebView alloc] init];
        [self.view addSubview:_web];
        id topGuide = self.topLayoutGuide;
        id bottomGuide = self.bottomLayoutGuide;
        _web.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[_web]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_web)]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[topGuide]-0-[_web]-0-[bottomGuide]" options:0 metrics:nil views:NSDictionaryOfVariableBindings(_web,topGuide,bottomGuide)]];
    }
    return _web;
}
-(UIView *)progressView{
    if (!_progressView) {
        _progressView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 2)];
        _progressView.backgroundColor = self.view.tintColor;
        [self.view addSubview:_progressView];
    }
    return _progressView;
}
-(void)updateProgress {
    if (self.web.estimatedProgress == 0 || self.web.estimatedProgress == 1) {
        self.progressView.hidden = YES;
        return;
    }
    self.view.hidden = NO;
    [self.view bringSubviewToFront:self.progressView];
    self.progressView.frame = CGRectMake(0, self.web.frame.origin.y, self.web.frame.size.width * self.web.estimatedProgress, 2);
}
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self performSelectorOnMainThread:@selector(updateProgress) withObject:nil waitUntilDone:NO];
    }
}

-(void)loadFromParma{
    if (self.parma) {
        self.url = self.parma[keyWebVCUrl];
        self.parmaDic = self.parma[keyWebVCParma];
        if (self.parmaDic) {
            [self loadIsGet:(self.parma[keyWebVCGET] && [self.parma[keyWebVCGET] boolValue]) url:self.url parma:self.parmaDic web:self.web];
        }else{
            if ([self.url rangeOfString:@"://"].location == NSNotFound) {
                self.url = [@"http://" stringByAppendingString:self.url];
            }
            [self.web loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
        }
    }
}
-(void)viewDidLoad{
    [super viewDidLoad];
    if (!self.returnImage) [self addWebviewReturnButton:nil];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.hidesBottomBarWhenPushed = YES;
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor=[UIColor whiteColor];
    
    self.web.navigationDelegate = self;
    [self.web addObserver:self forKeyPath:@"estimatedProgress" options:(NSKeyValueObservingOptionNew) context:nil];
    [self loadFromParma];
    
}
-(void)dealloc {
    [self.web removeObserver:self forKeyPath:@"estimatedProgress"];
}
-(void)creatBtnArray{
    __weak typeof(self) weak_self = self;
    
    XYButton* btn1 = [[XYButton new] set_customUI:^(UIView *theView) {
        theView.backgroundColor = [UIColor whiteColor];
        ImageCreate(101);
        image_101.image = weak_self.returnImage;
        LabelCreate(102);
        label_102.textColor = [UIColor blackColor];
        label_102.text = @"返回";
        label_102.textAlignment = NSTextAlignmentCenter;
        label_102.font = [UIFont systemFontOfSize:15 weight:UIFontWeightThin];
    } layOut:^(UIView *theView) {
        Image(101).frame = CGRectMake(0, 0, 10, theView.frame.size.height);
        Label(102).frame = CGRectMake(10, 0, theView.frame.size.width-10, theView.frame.size.height);
    } callBack:^(BOOL isSelected, UIView *theView) {
        [weak_self back];
    } touched:nil messgaeSet:nil];
    btn1.frame = CGRectMake(0, 0, 50, 40);
    UIBarButtonItem* item1 = [[UIBarButtonItem alloc] initWithCustomView:btn1];
    XYButton* btn2 = [[XYButton new] set_customUI:^(UIView *theView) {
        theView.backgroundColor = [UIColor whiteColor];
        LabelCreate(102);
        label_102.textColor = [UIColor blackColor];
        label_102.text = @"关闭";
        label_102.textAlignment = NSTextAlignmentCenter;
        label_102.font = [UIFont systemFontOfSize:15 weight:UIFontWeightThin];
    } layOut:^(UIView *theView) {
        Label(102).frame = CGRectMake(0, 0, theView.frame.size.width, theView.frame.size.height);
    } callBack:^(BOOL isSelected, UIView *theView) {
        [weak_self.navigationController popViewControllerAnimated:YES];
    } touched:nil messgaeSet:nil];
    btn2.frame = CGRectMake(0, 0, 40, 40);
    UIBarButtonItem* item2 = [[UIBarButtonItem alloc] initWithCustomView:btn2];
    self.btnArray = @[item1,item2];
}
-(void)loadIsGet:(BOOL)isGet url:(NSString*)url parma:(NSDictionary*)parma web:(WKWebView*)web{
    //    if (isGet) {
    //        [XYNet GETUrl:url Parma:parma HeaderParma:nil downloadProgress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nonnull responseObject, NSInteger code, NSString * _Nullable info) {
    //            DLogVerbose(@"\n%@\n%@\n%@",task.originalRequest,task.currentRequest,task.response);
    //            if ([responseObject isKindOfClass:[NSString class]]) {
    //                [web loadHTMLString:responseObject baseURL:nil];
    //            }else if ([responseObject isKindOfClass:[NSData class]]){
    //                NSString *string111 =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
    //                [web loadHTMLString:string111 baseURL:nil];
    //            }
    //        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
    //            DLogVerbose(@"\n%@\n%@\n%@",task.originalRequest,task.currentRequest,task.response);
    //            if (task.currentRequest) {
    //                [web loadRequest:task.currentRequest];
    //            }
    //        } hudInView:web.superview];
    //    }else{
    //        [XYNet POSTUrl:url Parma:nil BodyParma:parma HeaderParma:nil uploadProgress:nil downloadProgress:nil success:^(NSURLSessionDataTask * _Nullable task, id  _Nonnull responseObject, NSInteger code, NSString * _Nullable info) {
    //            DLogVerbose(@"\n%@\n%@\n%@",task.originalRequest,task.currentRequest,task.response);
    //            if ([responseObject isKindOfClass:[NSString class]]) {
    //                [web loadHTMLString:responseObject baseURL:nil];
    //            }else if ([responseObject isKindOfClass:[NSData class]]){
    //                NSString *string111 =  [[NSString alloc]initWithData:responseObject encoding:NSUTF8StringEncoding];
    //                [web loadHTMLString:string111 baseURL:nil];
    //            }
    //        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nullable error) {
    //            DLogVerbose(@"\n%@\n%@\n%@",task.originalRequest,task.currentRequest,task.response);
    //            if (task.currentRequest) {
    //                [web loadRequest:task.currentRequest];
    //            }
    //        } hudInView:web.superview cache:nil cacheType:XYZHttpCacheTypeDefault];
    //    }
}
-(void)back{
    if ([self.web canGoBack]){
        [self.web goBack];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
        if (title && [title isKindOfClass:[NSString class]] && ((NSString*)title).length > 0) {
            self.title = (NSString*)title;
        }
    }];
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
        if (!self.btnArray) [self creatBtnArray];
        self.navigationItem.leftBarButtonItems = self.btnArray;
    }
    decisionHandler(WKNavigationActionPolicyAllow);
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.hidden = YES;
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.hidden = YES;
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView *)webView {
    self.progressView.hidden = YES;
}
@end
