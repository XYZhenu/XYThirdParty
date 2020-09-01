//
//  XYCollectionViewController.m
//  AFNetworking
//
//  Created by xyzhenu on 2019/5/29.
//

#import "XYCollectionViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "Log.h"
#import <objc/runtime.h>
#define XYTableKey(_C_) static char kTable##_C_##Key
#define XYTableSET(_O_,_K_) objc_setAssociatedObject(self, &_K_, _O_, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
#define XYTableSETAssign(_O_,_K_) objc_setAssociatedObject(self, &_K_, _O_, OBJC_ASSOCIATION_ASSIGN)
#define XYTableGET(_K_) objc_getAssociatedObject(self, &_K_)

@interface UICollectionReusableView (_XYLayout)
- (CGSize)autoLayoutSizeWithWidth:(CGFloat)contentViewWidth;
@end
@implementation UICollectionReusableView (_XYLayout)

- (CGSize)autoLayoutSizeWithWidth:(CGFloat)contentViewWidth{
    
    CGSize fittingSize = CGSizeZero;
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];
    
    [self addConstraint:widthFenceConstraint];
    
    // Auto layout engine does its math
    fittingSize = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    // Clean-ups
    [self removeConstraint:widthFenceConstraint];
    
    if (fittingSize.width == 0 || fittingSize.height == 0) {
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (self.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[UICollectionReusableView] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        fittingSize = [self sizeThatFits:CGSizeMake(contentViewWidth, 0)];
    }
    
    return fittingSize;
}

@end

@implementation UICollectionReusableView (XYRowModel)
XYTableKey(DelegateCell);
-(void)setXyModelDelegate:(id<XYModelDelegate>)xyModelDelegate {
    XYTableSETAssign(xyModelDelegate, kTableDelegateCellKey);
}
-(id<XYModelDelegate>)xyModelDelegate {
    return XYTableGET(kTableDelegateCellKey);
}

XYTableKey(ModelCell);
-(void)setXyModel:(XYRowModel *)xyModel {
    XYTableSET(xyModel, kTableModelCellKey);
    [self xyModelSet:xyModel];
}
-(XYRowModel *)xyModel {
    return XYTableGET(kTableModelCellKey);
}

-(void)xyModelSet:(XYRowModel *)model {}
+(CGSize)xySizeWithModel:(XYRowModel*)model maxWidth:(CGFloat)width {return CGSizeMake(0, -2);}
@end


@interface XYCollectionViewController ()
@property(nonatomic,strong)UICollectionView*xy_collectionView;
@property(nonatomic,assign) BOOL xy_isRect;
@property (nonatomic,strong)NSMutableDictionary* cellForCaculating;
@property (atomic, assign)BOOL isHeaderTriggerLastToken;
@property (atomic, assign)BOOL isFooterRefreshToken;
@end

@implementation XYCollectionViewController

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rowsPerPage = 10;
        self.xy_isRect = NO;
        self.ModelRect = [NSMutableArray array];
        self.operateRect = self.ModelRect;
        self.cellForCaculating = [NSMutableDictionary dictionary];
        self.shouldAutoLoadMore = YES;
        self.isRefreshing = NO;
        self.isFooterRefreshToken = NO;
        self.alwaysHideTabbar = NO;
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.rowsPerPage = 10;
    self.xy_isRect = NO;
    self.ModelRect = [NSMutableArray array];
    self.operateRect = self.ModelRect;
    self.cellForCaculating = [NSMutableDictionary dictionary];
    self.shouldAutoLoadMore = YES;
    self.isRefreshing = NO;
    self.isFooterRefreshToken = NO;
    self.alwaysHideTabbar = NO;
}
-(BOOL)shouldAutorotate{
    return YES;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
    return UIInterfaceOrientationPortrait;
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = NO;
    self.navigationController.navigationBar.translucent=NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    if (self.navigationController.viewControllers.firstObject != self || self.alwaysHideTabbar) {
        self.tabBarController.tabBar.hidden=YES;
        self.tabBarController.tabBar.translucent=YES;
    }else{
        self.tabBarController.tabBar.hidden=NO;
        self.tabBarController.tabBar.translucent=NO;
    }
}
-(void)setRowsPerPage:(NSUInteger)rowsPerPage {
    if (rowsPerPage > 1) {
        _rowsPerPage = rowsPerPage;
    }
}
-(NSUInteger)currentItemCount {
    return self.operateRect.count;
}
-(NSUInteger)currentPage {
    NSUInteger page = (NSUInteger)([self currentItemCount] / self.rowsPerPage);
    if ([self currentItemCount] % self.rowsPerPage > 0 && [self currentItemCount] > self.rowsPerPage) {
        page ++;
    }
    return page;
}
-(UICollectionViewFlowLayout *)flowLayout {
    if (!_flowLayout) {
        _flowLayout = [UICollectionViewFlowLayout new];
    }
    return _flowLayout;
}
-(UICollectionView *)xy_collectionView {
    if (!_xy_collectionView) {
        _xy_collectionView=[[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:self.flowLayout];
        _xy_collectionView.delegate=self;
        _xy_collectionView.dataSource=self;
        _xy_collectionView.backgroundColor = [UIColor clearColor];
        [self bindRefreshHeader:_xy_collectionView withText:NO];
        [self bindRefreshFooter:_xy_collectionView];
        if ([_xy_collectionView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_xy_collectionView setLayoutMargins: UIEdgeInsetsZero];
        }
        [self.view addSubview:_xy_collectionView];
    }
    return _xy_collectionView;
}
-(void)bindCollectionView:(UICollectionView*)collectionView {
    [self bindCollectionView:collectionView isRect:NO];
}
-(void)bindCollectionView:(UICollectionView*)collectionView isRect:(BOOL)isrect{
    self.xy_isRect = isrect;
    if (!collectionView.collectionViewLayout) {
        collectionView.collectionViewLayout = self.flowLayout;
    }
    collectionView.delegate=self;
    collectionView.dataSource=self;
    _xy_collectionView = collectionView;
    _xy_collectionView.backgroundColor = [UIColor clearColor];
    if ([_xy_collectionView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_xy_collectionView setLayoutMargins: UIEdgeInsetsZero];
    }
    _xy_collectionView.backgroundView = nil;
    _xy_collectionView.backgroundColor = [UIColor clearColor];
}
-(void)bindRefreshHeader:(UICollectionView*)collectionView withText:(BOOL)withText {
    if (collectionView) {
        MJRefreshNormalHeader*header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(xy_refreshHeader)];
        if (!withText) {
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
        }
        collectionView.mj_header = header;
        _xy_collectionView = collectionView;
    }else{
        _xy_collectionView.mj_header = nil;
    }
}
-(void)bindRefreshFooter:(UICollectionView*)collectionView {
    if (collectionView) {
        MJRefreshAutoNormalFooter* footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(xy_refreshFooter)];
        collectionView.mj_footer = footer;
        //        [footer setTitle:@"" forState:MJRefreshStateIdle];
        //        [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
        [footer setTitle:@"" forState:MJRefreshStatePulling];
        //        [footer setTitle:@"" forState:MJRefreshStateRefreshing];
        [footer setTitle:@"" forState:MJRefreshStateWillRefresh];
        //        footer.stateLabel.hidden = YES;
        _xy_collectionView = collectionView;
    }else{
        _xy_collectionView.mj_footer = nil;
    }
}
-(void)showNoMoreData:(BOOL)show{
    [(MJRefreshAutoNormalFooter*)self.xy_collectionView.mj_footer setTitle:show ? @"没有更多数据啦" : @"点击或上拉加载更多" forState:MJRefreshStateIdle];
}
-(void)adjustFooterLabel{
    BOOL hidden = [self currentItemCount]==0;
    [(MJRefreshAutoNormalFooter*)self.xy_collectionView.mj_footer setTitle:hidden ? @"" : @"没有更多数据啦" forState:MJRefreshStateIdle];
}
-(void)endRefreshing {
    [_xy_collectionView.mj_header endRefreshing];
    [_xy_collectionView.mj_footer endRefreshing];
}
-(void)xy_refreshHeader {
    [self refreshHeaderSilently:YES];
}
-(void)refreshHeaderSilently:(BOOL)silently {
    if (!silently) {
        [NSOperationQueue.mainQueue addOperationWithBlock:^{
            [self.xy_collectionView.mj_header beginRefreshing];
            [self.xy_collectionView.mj_footer setHidden:true];
        }];
        return;
    }
    self.isHeaderTriggerLastToken = YES;
    self.isRefreshing = YES;
    __weak typeof(self) weak_self = self;
    [self refresh:self.xy_collectionView page:0 complete:^(NSArray * _Nullable modelRect, BOOL finished) {
        if (weak_self.isHeaderTriggerLastToken) {
            if (modelRect) {
                NSUInteger currentCount = [self currentItemCount];
                [weak_self.operateRect removeObjectsInRange:NSMakeRange(weak_self.operateRect.count - currentCount, currentCount)];
                [weak_self.operateRect addObjectsFromArray:modelRect];
                if (weak_self.ModelRect.count>0 && [weak_self.ModelRect.firstObject isKindOfClass:[XYSectionModel class]]) weak_self.xy_isRect = YES;
                [weak_self.xy_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            if (finished) {
                [weak_self endRefreshing];
                weak_self.isRefreshing = NO;
                [weak_self adjustFooterLabel];
            }
        }
        if (finished) {
            [weak_self.xy_collectionView.mj_header endRefreshing];
            [weak_self.xy_collectionView.mj_footer setHidden:false];
        }
    }];
}
-(void)xy_refreshFooter {
    [self refreshFooterSilently:YES];
}
-(void)refreshFooterSilently:(BOOL)silently {
    if (!silently) {
        [self.xy_collectionView.mj_footer beginRefreshing];
        return;
    }
    if (self.isFooterRefreshToken) return;
    self.isFooterRefreshToken = YES;
    NSUInteger completePage = [self currentItemCount] / self.rowsPerPage;
    __block NSUInteger unCompleteNum = [self currentItemCount] % self.rowsPerPage;
    self.isHeaderTriggerLastToken = NO;
    self.isRefreshing = YES;
    __weak typeof(self) weak_self = self;
    [self refresh:self.xy_collectionView page:completePage complete:^(NSArray * _Nullable modelRect, BOOL finished) {
        if (!weak_self.isHeaderTriggerLastToken) {
            if (modelRect) {
                [weak_self.operateRect removeObjectsInRange:NSMakeRange(weak_self.operateRect.count - unCompleteNum, unCompleteNum)];
                [weak_self.operateRect addObjectsFromArray:modelRect];
                [weak_self.xy_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                unCompleteNum = modelRect.count;
            }
            if (finished) {
                [weak_self endRefreshing];
                weak_self.isRefreshing = NO;
                if (weak_self.shouldAutoLoadMore) {
                    if (!modelRect || modelRect.count==0 || modelRect.count%weak_self.rowsPerPage>0) [weak_self showNoMoreData:YES];
                    else [weak_self showNoMoreData:NO];
                }
                [weak_self adjustFooterLabel];
            }
        }
        if (finished) {
            [weak_self.xy_collectionView.mj_footer endRefreshing];
            weak_self.isFooterRefreshToken = NO;
        }
    }];
}

- (void)refresh:(UICollectionView*)collectionView page:(NSUInteger)page complete:(void (^)(NSArray* _Nullable, BOOL))complete {
    complete(nil, YES);
}

#pragma mark - xyzdeleate

-(void)XYModelResponse:(XYRowModel* )model{}

#pragma mark - collectionView num
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return self.xy_isRect ? self.ModelRect.count : 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.xy_isRect?((XYSectionModel*)self.ModelRect[section]).rows.count:self.ModelRect.count;
}

#pragma mark - cell

-(UICollectionViewCell*)getReuseCellWithModel:(XYRowModel*)data collectionView:(UICollectionView*)collectionView indexPath:(NSIndexPath*)indexPath {
    NSString* identi = data.identifier;
    UICollectionViewCell* cell = [collectionView dequeueReusableCellWithReuseIdentifier:identi forIndexPath:indexPath];
    if (!cell) {
        DDLogVerbose(@"\n没有注册这种cell， 现在通过 alloc init 创建\n%@",data);
        cell = [[data.cls alloc] init];
    }
    cell.xyModelDelegate    = self;
    cell.xyModel     = data;
    return cell;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    XYRowModel*data = self.xy_isRect?((XYSectionModel*)self.ModelRect[indexPath.section]).rows[indexPath.row]:self.ModelRect[indexPath.row];
    data.index = indexPath;
    UICollectionViewCell* cell = [self getReuseCellWithModel:data collectionView:collectionView indexPath:indexPath];
    return cell;
}
#pragma mark - cell height

-(CGSize)getReuseCellSizeWithModel:(XYRowModel*)data collectionView:(UICollectionView*)collectionView index:(NSIndexPath*)index{
    __block CGSize size = CGSizeZero;
    //    DDLogInfo(@"normal section %ld  row %ld   width %f",index.section,index.row,collectionView.bounds.size.width);
    @try {
        if (data.size.height > 0 && data.size.width > 0 && fabs(data._width - collectionView.bounds.size.width) < 0.0001) {
            size = data.size;
        }else{
            size=[data.cls xySizeWithModel:data maxWidth:collectionView.frame.size.width];
            if (size.height<=0) {
                UICollectionViewCell* cell = self.cellForCaculating[data.identifier];
                if (!cell) {
                    cell = [self getReuseCellWithModel:data collectionView:collectionView indexPath:index];
                    self.cellForCaculating[data.identifier] = cell;
                }else{
                    cell.xyModel = data;
                }
                data._width = collectionView.bounds.size.width;
                size = [cell autoLayoutSizeWithWidth:data._width];
                data.size = size;
            }
            //                DDLogInfo(@"caculate section %ld  row %ld   width %f",index.section,index.row,collectionView.bounds.size.width);
        }
    } @catch (NSException *exception) {
        DDLogError(@"%@",exception);
        size = CGSizeMake(100, 100);
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    XYRowModel*data = self.xy_isRect?((XYSectionModel*)self.ModelRect[indexPath.section]).rows[indexPath.row]:self.ModelRect[indexPath.row];
    data.index = indexPath;
    if (data) {
        return [self getReuseCellSizeWithModel:data collectionView:collectionView index:indexPath];
    }
    return CGSizeMake(100, 100);
}

#pragma mark - header footer

-(UICollectionReusableView*)getReuseHeaderFooterWithModel:(XYRowModel*)data collectionView:(UICollectionView*)collectionView kind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView* cell = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:data.identifier forIndexPath:indexPath];
    if (!cell) {
        //        DDLogVerbose(@"\n没有注册这种 header， 现在通过 alloc init 创建\n%@",data);
        cell                = [[data.cls alloc] init];
    }
    cell.xyModelDelegate    = self;
    cell.xyModel     = data;
    return cell;
}
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    XYSectionModel*data = self.xy_isRect?self.ModelRect[indexPath.section]:nil;
    if (data.header && [kind isEqualToString:UICollectionElementKindSectionHeader]) {
        return [self getReuseHeaderFooterWithModel:data.header collectionView:collectionView kind:kind atIndexPath:indexPath];
    } else if (data.footer && [kind isEqualToString:UICollectionElementKindSectionFooter]) {
        return [self getReuseHeaderFooterWithModel:data.footer collectionView:collectionView kind:kind atIndexPath:indexPath];
    }
    return [[UICollectionReusableView alloc] init];
}

#pragma mark - header footer height

-(CGSize)getReuseHeaderFooterSizeWithModel:(XYRowModel*)data collectionView:(UICollectionView*)collectionView{
    __block CGSize size = CGSizeZero;
    @try {
        if (data.height>0) {
            size = data.size;
        }else{
            size=[data.cls xySizeWithModel:data maxWidth:collectionView.frame.size.width];
            data.size = size;
        }
    } @catch (NSException *exception) {
        DDLogError(@"%@",exception);
        size = CGSizeMake(100, 100);
    }
    if (size.height<0.01) {
        size.height = 0.01;
    }
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    XYSectionModel*data = self.xy_isRect?self.ModelRect[section]:nil;
    if (data.header) {
        return [self getReuseHeaderFooterSizeWithModel:data.header collectionView:collectionView];
    }
    return CGSizeZero;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForFooterInSection:(NSInteger)section {
    XYSectionModel*data = self.xy_isRect?self.ModelRect[section]:nil;
    if (data.footer) {
        return [self getReuseHeaderFooterSizeWithModel:data.footer collectionView:collectionView];
    }
    return CGSizeZero;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (!self.shouldAutoLoadMore) return;
    if (!self.xy_collectionView.mj_footer) return;
    if (self.isRefreshing) return;
    NSInteger currentCount = [self currentItemCount];
    if (currentCount == 0) return;
    if (currentCount % self.rowsPerPage > 0) return;
    if (scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.frame.size.height > self.view.frame.size.height / 2) return;
    [self refreshFooterSilently:true];
}
@end
