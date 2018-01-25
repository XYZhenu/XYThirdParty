//
//  XYTableViewController.m
//  XYCategories
//
//  Created by xyzhenu on 2017/6/9.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import "XYTableViewController.h"
#import <MJRefresh/MJRefresh.h>
#import "Log.h"
#import <objc/runtime.h>
#define XYTableKey(_C_) static char kTable##_C_##Key
#define XYTableSET(_O_,_K_) objc_setAssociatedObject(self, &_K_, _O_, OBJC_ASSOCIATION_RETAIN_NONATOMIC)
#define XYTableSETAssign(_O_,_K_) objc_setAssociatedObject(self, &_K_, _O_, OBJC_ASSOCIATION_ASSIGN)
#define XYTableGET(_K_) objc_getAssociatedObject(self, &_K_)
@implementation XYRowModel
- (instancetype)initCls:(Class)cls msg:(NSDictionary *)msg
{
    self = [super init];
    if (self) {
        self.cls = cls;
        self.message = msg;
        self.height = -1;
        self._width = 320;
        self.model = nil;
    }
    return self;
}
-(void)setCls:(Class)cls {
    _cls = cls;
    self.identifier = [NSStringFromClass(cls) stringByReplacingOccurrencesOfString:[[NSBundle mainBundle].infoDictionary[@"CFBundleExecutable"]stringByAppendingString:@"."] withString:@""];
}
@end

@implementation XYSectionModel
-(instancetype)initRows:(NSArray<XYRowModel*>*)rows msg:(nullable NSDictionary<NSString*,id>*)msg {
    self = [super init];
    if (self) {
        self.rows = [NSMutableArray arrayWithArray:rows];
        self.message = msg;
    }
    return self;
}
-(instancetype)initOCRows:(NSMutableArray*)rows msg:(nullable NSDictionary*)msg{
    self = [super init];
    if (self) {
        self.rows = rows;
        self.message = msg;
    }
    return self;
}
@end

@interface UITableViewCell (_XYTableLayout)
- (CGFloat)autoLayoutHeightWithWidth:(CGFloat)width;
@end
@implementation UITableViewCell (_XYTableLayout)

- (CGFloat)autoLayoutHeightWithWidth:(CGFloat)contentViewWidth{

    CGFloat fittingHeight = 0;
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:contentViewWidth];

    // [bug fix] after iOS 10.3, Auto Layout engine will add an additional 0 width constraint onto cell's content view, to avoid that, we add constraints to content view's left, right, top and bottom.
    static BOOL isSystemVersionEqualOrGreaterThen10_2 = NO;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        isSystemVersionEqualOrGreaterThen10_2 = [UIDevice.currentDevice.systemVersion compare:@"10.2" options:NSNumericSearch] != NSOrderedAscending;
    });
    NSArray<NSLayoutConstraint *> *edgeConstraints;
    if (isSystemVersionEqualOrGreaterThen10_2) {
        // To avoid confilicts, make width constraint softer than required (1000)
        widthFenceConstraint.priority = UILayoutPriorityRequired - 1;

        // Build edge constraints
        NSLayoutConstraint *leftConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0];
        NSLayoutConstraint *rightConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0 constant:0];
        NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0];
//        NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:self.contentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0];
        edgeConstraints = @[leftConstraint, rightConstraint, topConstraint];
        [self addConstraints:edgeConstraints];
    }

    [self.contentView addConstraint:widthFenceConstraint];

    // Auto layout engine does its math
    fittingHeight = [self.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;

    // Clean-ups
    [self.contentView removeConstraint:widthFenceConstraint];
    if (isSystemVersionEqualOrGreaterThen10_2) {
        [self removeConstraints:edgeConstraints];
    }

    if (fittingHeight == 0) {
#if DEBUG
        // Warn if using AutoLayout but get zero height.
        if (self.contentView.constraints.count > 0) {
            if (!objc_getAssociatedObject(self, _cmd)) {
                NSLog(@"[FDTemplateLayoutCell] Warning once only: Cannot get a proper cell height (now 0) from '- systemFittingSize:'(AutoLayout). You should check how constraints are built in cell, making it into 'self-sizing' cell.");
                objc_setAssociatedObject(self, _cmd, @YES, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
            }
        }
#endif
        fittingHeight = [self sizeThatFits:CGSizeMake(contentViewWidth, 0)].height;
    }

    return fittingHeight+1;
}

@end


@implementation UITableViewCell (XYRowModel)
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
+(CGFloat)xyHeightWithModel:(XYRowModel *)model width:(CGFloat)width {return -2;}
@end

@implementation UITableViewHeaderFooterView (XYRowModel)
XYTableKey(DelegateHeader);
-(void)setXyModelDelegate:(id<XYModelDelegate>)xyModelDelegate {
    XYTableSETAssign(xyModelDelegate, kTableDelegateHeaderKey);
}
-(id<XYModelDelegate>)xyModelDelegate {
    return XYTableGET(kTableDelegateHeaderKey);
}

XYTableKey(ModelHeader);
-(void)setXyModel:(XYRowModel *)xyModel {
    XYTableSET(xyModel, kTableModelHeaderKey);
    [self xyModelSet:xyModel];
}
-(XYRowModel *)xyModel {
    return XYTableGET(kTableModelHeaderKey);
}

-(void)xyModelSet:(XYRowModel *)model {}
+(CGFloat)xyHeightWithModel:(XYRowModel *)model width:(CGFloat)width {return -2;}
@end




@interface XYTableViewController ()
@property(nonatomic,strong)UITableView*xy_tableView;
@property(nonatomic,assign) BOOL xy_isRect;


@property (nonatomic,strong)NSMutableDictionary* cellForCaculating;
@property (atomic, assign)BOOL isHeaderTriggerLastToken;
@end

@implementation XYTableViewController
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rowsPerPage = 10;
        self.xy_isRect = NO;
        self.ModelRect = [NSMutableArray array];
        self.operateRect = self.ModelRect;
        self.cellForCaculating = [NSMutableDictionary dictionary];
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
    if (self.navigationController.viewControllers.firstObject == self) {
        self.tabBarController.tabBar.hidden=NO;
        self.tabBarController.tabBar.translucent=NO;
    }else{
        self.tabBarController.tabBar.hidden=YES;
        self.tabBarController.tabBar.translucent=YES;
    }
    [[UIApplication sharedApplication] setStatusBarOrientation:UIInterfaceOrientationPortrait animated:NO];
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
-(UITableView *)xy_tableView{
    if (!_xy_tableView) {
        _xy_tableView=[[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _xy_tableView.delegate=self;
        _xy_tableView.dataSource=self;
        _xy_tableView.backgroundColor = [UIColor clearColor];
        _xy_tableView.estimatedRowHeight = 0;
        [self bindRefreshHeader:_xy_tableView withText:NO];
        [self bindRefreshFooter:_xy_tableView];
        if ([_xy_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
            [_xy_tableView setSeparatorInset: UIEdgeInsetsZero];
        }
        if ([_xy_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
            [_xy_tableView setLayoutMargins: UIEdgeInsetsZero];
        }
        _xy_tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [self.view addSubview:_xy_tableView];
    }
    return _xy_tableView;
}
-(void)bindTableView:(UITableView*)tableview {
    [self bindTableView:tableview isRect:NO];
}
-(void)bindTableView:(UITableView*)tableview isRect:(BOOL)isrect{
    if (!tableview.tableFooterView) {
        tableview.tableFooterView = [[UIView alloc] init];
    }
    self.xy_isRect = isrect;
    tableview.delegate=self;
    tableview.dataSource=self;
    _xy_tableView = tableview;
    _xy_tableView.estimatedRowHeight = 0;
    _xy_tableView.backgroundColor = [UIColor clearColor];
    if ([_xy_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_xy_tableView setSeparatorInset: UIEdgeInsetsZero];
    }
    if ([_xy_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_xy_tableView setLayoutMargins: UIEdgeInsetsZero];
    }
    _xy_tableView.backgroundView = nil;
    _xy_tableView.backgroundColor = [UIColor clearColor];
}
-(void)bindRefreshHeader:(UITableView*)tableview withText:(BOOL)withText {
    if (tableview) {
        MJRefreshNormalHeader*header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(xy_refreshHeader)];
        if (!withText) {
            header.lastUpdatedTimeLabel.hidden = YES;
            header.stateLabel.hidden = YES;
        }
        tableview.mj_header = header;
        _xy_tableView = tableview;
    }else{
        _xy_tableView.mj_header = nil;
    }
}
-(void)bindRefreshFooter:(UITableView*)tableview {
    if (tableview) {
        MJRefreshAutoNormalFooter* footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(xy_refreshFooter)];
        tableview.mj_footer = footer;
//        [footer setTitle:@"" forState:MJRefreshStateIdle];
//        [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
        [footer setTitle:@"" forState:MJRefreshStatePulling];
//        [footer setTitle:@"" forState:MJRefreshStateRefreshing];
        [footer setTitle:@"" forState:MJRefreshStateWillRefresh];
//        footer.stateLabel.hidden = YES;
        _xy_tableView = tableview;
    }else{
        _xy_tableView.mj_footer = nil;
    }
}

-(void)endRefreshing {
    [_xy_tableView.mj_header endRefreshing];
    [_xy_tableView.mj_footer endRefreshing];
}
-(void)xy_refreshHeader {
    [self refreshHeaderSilently:YES];
}
-(void)refreshHeaderSilently:(BOOL)silently {
    if (!silently) {
        [self.xy_tableView.mj_header beginRefreshing];
        [self.xy_tableView.mj_footer setHidden:true];
        return;
    }
    self.isHeaderTriggerLastToken = YES;
    __weak typeof(self) weak_self = self;
    [self refresh:self.xy_tableView page:0 complete:^(NSArray * _Nullable modelRect) {
        if (weak_self.isHeaderTriggerLastToken) {
            if (modelRect) {
                NSUInteger currentCount = [self currentItemCount];
                [weak_self.operateRect removeObjectsInRange:NSMakeRange(weak_self.operateRect.count - currentCount, currentCount)];
                [weak_self.operateRect addObjectsFromArray:modelRect];
                if (weak_self.ModelRect.count>0 && [weak_self.ModelRect.firstObject isKindOfClass:[XYSectionModel class]]) weak_self.xy_isRect = YES;
                [weak_self.xy_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            [weak_self endRefreshing];
        }
        [weak_self.xy_tableView.mj_header endRefreshing];
        [self.xy_tableView.mj_footer setHidden:false];
    }];
}
-(void)xy_refreshFooter {
    [self refreshFooterSilently:YES];
}
-(void)refreshFooterSilently:(BOOL)silently {
    if (!silently) {
        [self.xy_tableView.mj_footer beginRefreshing];
        return;
    }
    NSUInteger completePage = [self currentItemCount] / self.rowsPerPage;
    NSUInteger unCompleteNum = [self currentItemCount] % self.rowsPerPage;
    self.isHeaderTriggerLastToken = NO;
    __weak typeof(self) weak_self = self;
    [self refresh:self.xy_tableView page:completePage complete:^(NSArray<NSDictionary *> * _Nullable modelRect) {
        if (!weak_self.isHeaderTriggerLastToken) {
            if (modelRect) {
                [weak_self.operateRect removeObjectsInRange:NSMakeRange(weak_self.operateRect.count - unCompleteNum, unCompleteNum)];
                [weak_self.operateRect addObjectsFromArray:modelRect];
                [weak_self.xy_tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
            [weak_self endRefreshing];
        }
        [weak_self.xy_tableView.mj_footer endRefreshing];
    }];
}
-(void)refresh:(UITableView*)tableView page:(NSUInteger)page complete:(void (^)(NSArray* _Nullable))complete {
    complete(nil);
}



#pragma mark - xyzdeleate

-(void)XYModelResponse:(XYRowModel* )model{}

#pragma mark - tableview num

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.xy_isRect ? self.ModelRect.count : 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.xy_isRect?((XYSectionModel*)self.ModelRect[section]).rows.count:self.ModelRect.count;
}

#pragma mark - cell

-(UITableViewCell*)getReuseCellWithModel:(XYRowModel*)data tableview:(UITableView*)tableView{
    NSString* identi = data.identifier;
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:identi];
    if (!cell) {
        DDLogVerbose(@"\n没有注册这种cell， 现在通过 alloc init 创建\n%@",data);
        cell = [[data.cls alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.xyModelDelegate    = self;
    cell.xyModel     = data;
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XYRowModel*data = self.xy_isRect?((XYSectionModel*)self.ModelRect[indexPath.section]).rows[indexPath.row]:self.ModelRect[indexPath.row];
    data.index = indexPath;
    UITableViewCell* cell = [self getReuseCellWithModel:data tableview:tableView];
    return cell;
}

#pragma mark - cell height

-(CGFloat)getReuseCellHeightWithModel:(XYRowModel*)data tableview:(UITableView*)tableView index:(NSIndexPath*)index{
    __block CGFloat height = 0;
//    DDLogInfo(@"normal section %ld  row %ld   width %f",index.section,index.row,tableView.bounds.size.width);
    @try {
        if (data.height >= 0 && fabs(data._width - tableView.bounds.size.width) < 0.0001) {
            height = data.height;
        }else{
            height=[data.cls xyHeightWithModel:data width:tableView.frame.size.width];
            if (height<=0) {
                UITableViewCell* cell = self.cellForCaculating[data.identifier];
                if (!cell) {
                    cell = [self getReuseCellWithModel:data tableview:tableView];
                    self.cellForCaculating[data.identifier] = cell;
                }else{
                    cell.xyModel = data;
                }
                data._width = tableView.bounds.size.width;
                height = [cell autoLayoutHeightWithWidth:data._width];
                data.height = height;
            }
//                DDLogInfo(@"caculate section %ld  row %ld   width %f",index.section,index.row,tableView.bounds.size.width);
        }
    } @catch (NSException *exception) {
        DDLogError(@"%@",exception);
        height = 100;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XYRowModel*data = self.xy_isRect?((XYSectionModel*)self.ModelRect[indexPath.section]).rows[indexPath.row]:self.ModelRect[indexPath.row];
    data.index = indexPath;
    if (data) {
        return [self getReuseCellHeightWithModel:data tableview:tableView index:indexPath];
    }
    return 50;
}

#pragma mark - header

-(UITableViewHeaderFooterView*)getReuseHeaderWithModel:(XYRowModel*)data tableview:(UITableView*)tableView{
    UITableViewHeaderFooterView* cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:data.identifier];
    if (!cell) {
//        DDLogVerbose(@"\n没有注册这种 header， 现在通过 alloc init 创建\n%@",data);
        cell                = [[data.cls alloc] initWithReuseIdentifier:data.identifier];
    }
    cell.xyModelDelegate    = self;
    cell.xyModel     = data;
    return cell;
}

-(UIView* )tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    XYSectionModel*data = self.xy_isRect?self.ModelRect[section]:nil;
    if (data.header) {
        return [self getReuseHeaderWithModel:data.header tableview:tableView];
    }
    return [[UIView alloc] init];
}

#pragma mark - header height

-(CGFloat)getReuseHeaderHeightWithModel:(XYRowModel*)data tableview:(UITableView*)tableView{
    __block CGFloat height = 0.01;
    @try {
        if (data.height>0) {
            height = data.height;
        }else{
            height=[data.cls xyHeightWithModel:data width:tableView.frame.size.width];
            data.height = height;
        }
    } @catch (NSException *exception) {
        DDLogError(@"%@",exception);
        height = 100;
    }
    if (height<0.01) {
        height = 0.01;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    XYSectionModel*data = self.xy_isRect?self.ModelRect[section]:nil;
    if (data.header) {
        return [self getReuseHeaderHeightWithModel:data.header tableview:tableView];
    }
    return 0.01;
}

#pragma mark - footer

-(UITableViewHeaderFooterView*)getReuseFooterWithModel:(XYRowModel*)data tableview:(UITableView*)tableView{
    UITableViewHeaderFooterView* cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:data.identifier];
    if (!cell) {
//        DDLogVerbose(@"\n没有注册这种 footet， 现在通过 alloc init 创建\n%@",data);
        cell                = [[data.cls alloc] initWithReuseIdentifier:data.identifier];
    }
    cell.xyModelDelegate    = self;
    cell.xyModel            = data;
    return cell;
}

-(UIView* )tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    XYSectionModel*data = self.xy_isRect?self.ModelRect[section]:nil;
    if (data.footer) {
        return [self getReuseFooterWithModel:data.footer tableview:tableView];
    }
    return [[UIView alloc] init];
}

#pragma mark - footer height

-(CGFloat)getReuseFooterHeightWithModel:(XYRowModel*)data tableview:(UITableView*)tableView{
    __block CGFloat height = 0.01;
    @try {
        if (data.height>0) {
            height = data.height;
        }else{
            height=[data.cls xyHeightWithModel:data width:tableView.frame.size.width];
            data.height = height;
        }
    } @catch (NSException *exception) {
        DDLogError(@"%@",exception);
        height = 100;
    }
    if (height<0.01) {
        height = 0.01;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    XYSectionModel*data = self.xy_isRect?self.ModelRect[section]:nil;
    if (data.footer) {
        return [self getReuseFooterHeightWithModel:data.footer tableview:tableView];
    }
    return 0.01;
}
@end
