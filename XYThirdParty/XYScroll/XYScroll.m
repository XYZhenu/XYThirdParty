//
//  XYScroll.m
//  XYCategories
//
//  Created by xieyan on 2017/6/5.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "XYScroll.h"

@interface XYScroll ()<UIScrollViewDelegate>{
    NSMutableArray* _cellArray;
    NSTimer *_timer;
}

@property(nonatomic,strong)void(^callBack)(NSInteger index,UIView* theView,id message);

@property(nonatomic,strong)void(^messageSet)(NSInteger index,UIView* theView,id message);
@property(nonatomic,strong)CGRect(^indicatorRect)(CGRect bound);

@end
@implementation XYScroll


-(instancetype)init{
    self = [super init];
    if (self) {
        [self prepare];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self prepare];
    }
    return self;
}
-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self prepare];
    }
    return self;
}
-(void)prepare{
    self.bounces=NO;
    _currentPage = 0;
    _scrollInterval = 4;
    _animateInterval = 0.6;
    _enableInfiniteScroll = YES;
    _enableIndicator = NO;
    _enableTimer = NO;
    _cellArray = [NSMutableArray new];
    for (int i=0; i<3; i++) {
        UIView* view = [[UIView alloc] init];
        [_cellArray addObject:view];
        [self addSubview:view];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
        [view addGestureRecognizer:tap];
    }
    self.delegate = self;
    self.showsHorizontalScrollIndicator = NO;
    self.showsVerticalScrollIndicator = NO;
    self.pagingEnabled = YES;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    if (!self.enableInfiniteScroll && self.messageArray.count==2) {
        self.contentSize = CGSizeMake(self.frame.size.width*2, self.frame.size.height);
    }else{
        self.contentSize = CGSizeMake(self.frame.size.width*3, self.frame.size.height);
    }
    for (int i=0; i<3; i++) {
        UIView* view = _cellArray[i];
        view.frame = CGRectMake(i * CGRectGetWidth(self.frame), 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    }
    if (self.layOut) {
        for (int i=0; i<3; i++) {
            self.layOut(_cellArray[i]);
        }
    }
    if (self.enableIndicator && self.messageArray.count>1) {
        CGRect frame;
        if (self.indicatorRect) {
            frame = self.indicatorRect(self.bounds);
            frame.origin.x+=self.frame.origin.x;
            frame.origin.y+=self.frame.origin.y;
        }else{
            frame = CGRectMake(self.frame.origin.x, self.frame.origin.y+self.frame.size.height-20, self.frame.size.width, 20);
        }
        self.pageControl.frame = frame;
        [self.pageControl sizeToFit];
        [self.superview addSubview:self.pageControl];
        [self.superview bringSubviewToFront:self.pageControl];
    }else{
        if (_pageControl) {
            [_pageControl removeFromSuperview];
        }
    }
}
-(void)setLayOut:(void (^)(UIView *))layOut{
    _layOut = layOut;
    [self setNeedsLayout];
}






/**
 *  指示器有关
 *
 */
-(TAPageControl *)pageControl{
    if (!_pageControl) {
        _pageControl = [[TAPageControl alloc] init];
        _pageControl.dotImage = [UIImage imageNamed:@"dotImage"];
        _pageControl.currentDotImage = [UIImage imageNamed:@"currentdotImage"];
    }
    return _pageControl;
}

-(void)setIndicatorBGColor:(UIColor *)indicatorBGColor{
    if (_pageControl) {
        _pageControl.backgroundColor = indicatorBGColor;
    }
}
-(UIColor *)indicatorBGColor{
    if (_pageControl) {
        return _pageControl.backgroundColor;
    }else{
        return [UIColor clearColor];
    }
}


-(void)setEnableIndicator:(BOOL)enableIndicator{
    if (_enableIndicator==enableIndicator) {
        return;
    }
    _enableIndicator = enableIndicator;
    if (enableIndicator) {
        self.pageControl.numberOfPages = self.messageArray.count;
        self.pageControl.currentPage = _currentPage;
    }
    [self setNeedsLayout];
}



/**
 *  设置data
 */
-(void)setMessageArray:(NSArray *)messageArray{
    self.pagingEnabled = YES;
    if (messageArray == _messageArray && messageArray.count == _messageArray.count) {
        return;
    }
    [self willChangeValueForKey:@"messageArray"];

    [self resetData:messageArray];

    [self didChangeValueForKey:@"messageArray"];
}
-(void)resetData:(NSArray*)messageArray{
    [self stopTimer];
    _messageArray = messageArray;

    _currentPage = 0;
    if (_pageControl) {
        _pageControl.currentPage=0;
        _pageControl.numberOfPages = messageArray.count;
    }


    switch (messageArray.count) {
        case 0:{
            self.contentOffset = CGPointMake(0, 0);
            self.scrollEnabled = NO;
            if (self.messageSet) {
                self.messageSet(0,_cellArray[0],nil);
            }
            break;
        }
        case 1:{
            self.contentOffset = CGPointMake(0, 0);
            self.scrollEnabled = NO;
            if (self.messageSet) {
                self.messageSet(0,_cellArray[0],messageArray[0]);
            }
            break;
        }
        case 2:
            if (!self.enableInfiniteScroll) {
                self.enableTimer = NO;

                self.contentOffset = CGPointZero;
                self.scrollEnabled = YES;
                self.contentSize = CGSizeMake(self.frame.size.width*2, self.frame.size.height);
                if (self.messageSet) {
                    self.messageSet(0,_cellArray[0],messageArray[0]);
                    self.messageSet(1,_cellArray[1],messageArray[1]);
                }

                break;
            }
        default:{
            [self reloadData];
            self.scrollEnabled = YES;
            if (self.enableTimer) {
                [self startTimer];
            }
            break;
        }
    }
    [self setNeedsLayout];
}
-(void)reloadData{
    if (self.enableInfiniteScroll) {
        self.contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0);
        if (self.messageSet) {
            for (int i=0; i<3; i++) {
                NSInteger k = [self PageOfIndex:_currentPage-1+i];
                self.messageSet(k,_cellArray[i],self.messageArray[k]);
            }
        }
    }else if (self.messageArray.count>2){
        if (_currentPage==0) {
            self.contentOffset = CGPointMake(0, 0);
            if (self.messageSet) {
                for (int i=0; i<2; i++) {
                    self.messageSet(i,_cellArray[i],self.messageArray[i]);
                }
            }
        }else if (_currentPage==self.messageArray.count-1){
            self.contentOffset = CGPointMake(2*CGRectGetWidth(self.frame), 0);
            if (self.messageSet) {
                for (int i=2; i>0; i--) {
                    self.messageSet(i,_cellArray[i],self.messageArray[self.messageArray.count-1-2+i]);
                }
            }
        }else{
            self.contentOffset = CGPointMake(CGRectGetWidth(self.frame), 0);
            if (self.messageSet) {
                for (int i=0; i<3; i++) {
                    NSInteger k = _currentPage;
                    self.messageSet(k,_cellArray[i],self.messageArray[k]);
                }
            }
        }
    }

}

-(void)setEnableInfiniteScroll:(BOOL)enableInfiniteScroll{
    if (_enableInfiniteScroll==enableInfiniteScroll) {
        return;
    }
    if (!enableInfiniteScroll) {
        self.enableTimer = NO;
    }
    _enableInfiniteScroll = enableInfiniteScroll;
    [self resetData:_messageArray];
}






/**
 *  设置timer定时器
 */
- (void)startTimer
{
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:self.scrollInterval target:self selector:@selector(scrollPage) userInfo:nil repeats:YES];
    }
    if (![_timer isValid]) {
        [_timer fire];
    }

}
- (void)stopTimer
{
    if (_timer) {
        if ([_timer isValid]) {
            [_timer invalidate];
        }
        _timer = nil;
    }
}
-(void)setEnableTimer:(BOOL)enableTimer{
    if (!self.enableInfiniteScroll) {
        _enableTimer = NO;
        [self stopTimer];
    }


    if (_enableTimer == enableTimer) {
        return;
    }else{
        _enableTimer = enableTimer;
        if (_enableTimer) {
            [self startTimer];
        }else{
            [self stopTimer];
        }
    }
}
-(void)setScrollInterval:(CGFloat)scrollInterval{
    if (scrollInterval<1) {
        return;
    }
    _scrollInterval = scrollInterval;
    [self stopTimer];
    if (self.enableTimer) {
        [self startTimer];
    }
}
-(void)setAnimateInterval:(CGFloat)animateInterval{
    if (animateInterval<0.1 || animateInterval>1) {
        return;
    }
    _animateInterval = animateInterval;
    [self stopTimer];
    if (self.enableTimer) {
        [self startTimer];
    }
}






//翻页有关
- (NSInteger)PageOfIndex:(NSInteger)index
{
    if (index < 0) {
        index = self.messageArray.count - 1;
    }
    else if (index > self.messageArray.count - 1) {
        index = 0;
    }
    return index;
}
-(void)setCurrentPage:(NSInteger)currentPage{
    if (_currentPage == currentPage) {
        return;
    }
    _currentPage = currentPage;
    if (_pageControl) {
        _pageControl.currentPage = currentPage;
    }
    if (!self.enableInfiniteScroll && self.messageArray.count==2) {
        [self disableUserInteraction];
        //        [UIView animateWithDuration:self.animateInterval animations:^{
        CGPoint point;
        if (currentPage==0) {
            point  = CGPointMake(0, 0);
        }else{
            point = CGPointMake(CGRectGetWidth(self.frame), 0);
        }
        self.contentOffset = point;
        //        } completion:^(BOOL finished) {
        //            if (finished) {
        [self enableUserInteraction];
        //            }
        //        }];
    }else{
        [self reloadData];
    }

}
- (void)showNextPage
{
    self.currentPage = [self PageOfIndex:_currentPage + 1];
}
- (void)showLastPage
{
    self.currentPage = [self PageOfIndex:_currentPage - 1];
}
- (void)scrollPage
{
    [self disableUserInteraction];
    [UIView animateWithDuration:self.animateInterval animations:^{
        CGPoint point = CGPointMake(2 * CGRectGetWidth(self.frame), 0);
        self.contentOffset = point;
    } completion:^(BOOL finished) {
        if (finished) {
            [self showNextPage];
            [self enableUserInteraction];
        }
    }];
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat off = scrollView.contentOffset.x;
    if (!self.enableInfiniteScroll && self.messageArray.count==2) {
        if (_pageControl) {

            if (scrollView.contentOffset.x >= CGRectGetWidth(self.frame)/2) {
                _pageControl.currentPage = 1;
            }else{
                _pageControl.currentPage = 0;
            }

        }

    }else if(!self.enableInfiniteScroll && self.messageArray.count>2){
        NSInteger page = self.currentPage;
        if (page==0) {
            if (off<=0) {

            }else{
                self.currentPage=1;
            }
        }else if(page==self.messageArray.count-1){
            if (off>= 2 * CGRectGetWidth(self.frame)) {

            }else{
                self.currentPage=self.messageArray.count-2;
            }
        }else{
            if (scrollView.contentOffset.x >= 2 * CGRectGetWidth(self.frame)) {
                self.currentPage+=1;
            }
            else if (scrollView.contentOffset.x <= 0) {
                self.currentPage-=1;
            }
        }



    }else{
        if (scrollView.contentOffset.x >= 2 * CGRectGetWidth(self.frame)) {
            [self showNextPage];
        }
        else if (scrollView.contentOffset.x <= 0) {
            [self showLastPage];
        }
        if (self.enableTimer) {
            [self startTimer];
        }
    }




}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self stopTimer];
}








//点击有关
-(void)didTap:(UITapGestureRecognizer*)tap{
    if (self.callBack && self.messageArray.count > 0) {
        NSException *callException = nil;
        @try {
            self.callBack(self.currentPage,tap.view,self.messageArray[self.currentPage]);
        }
        @catch (NSException *exception) {
            callException = exception;
        }
        @finally {
            if (callException) {
                NSLog(@"XYZScroll  TapPage:%ld   callBack   failed",self.currentPage);
            }
        }
    }
}
-(void)disableUserInteraction{
    for (UIView* view in _cellArray) {
        view.userInteractionEnabled = NO;
        UIGestureRecognizer* ges = view.gestureRecognizers.firstObject;
        ges.enabled = NO;
    }
}
-(void)enableUserInteraction{
    for (UIView* view in _cellArray) {
        view.userInteractionEnabled = YES;
        UIGestureRecognizer* ges = view.gestureRecognizers.firstObject;
        ges.enabled = YES;
    }
}







-(void)setBackgroundColor:(UIColor *)backgroundColor{
    [super setBackgroundColor:backgroundColor];
    for (UIView* view in _cellArray) {
        view.backgroundColor = backgroundColor;
    }
}









+(instancetype)new{
    return [[self alloc] init];
}
-(instancetype)set_createUI:(void(^)(UIView* theView))createUI
                     layOut:(void(^)(UIView* theView))layOut
              indicatorRect:(CGRect(^)(CGRect bound))indicatorRect
                   callBack:(void(^)(NSInteger index,UIView* theView,id message))callBack
                 messgaeSet:(void(^)(NSInteger index,UIView* theView,id message))messageSet{
    self.callBack = callBack;
    self.layOut = layOut;
    self.indicatorRect = indicatorRect;
    self.messageSet = messageSet;
    if (createUI) {
        for (UIView* view in _cellArray) {
            for (UIView* subview in view.subviews) {
                [subview removeFromSuperview];
            }
            [self addSubview:view];
            createUI(view);
        }
    }
    [self layoutIfNeeded];
    return self;
}
@end

