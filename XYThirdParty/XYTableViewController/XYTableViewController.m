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

@end

@interface UIView (_XYTableLayout)
- (CGFloat)autoLayoutHeightWithWidth:(CGFloat)width;
@end
@implementation UIView (_XYTableLayout)

- (CGFloat)autoLayoutHeightWithWidth:(CGFloat)width{

    self.translatesAutoresizingMaskIntoConstraints = NO;
    NSLayoutConstraint *widthFenceConstraint = [NSLayoutConstraint constraintWithItem:self attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:width];
    [self addConstraint:widthFenceConstraint];
    CGFloat height = [self systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    [self removeConstraint:widthFenceConstraint];
    return height+1;
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
        self.cellForCaculating = [NSMutableDictionary dictionary];
    }
    return self;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.rowsPerPage = 10;
    self.xy_isRect = NO;
    self.ModelRect = [NSMutableArray array];
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
-(NSUInteger)currentPage {
    NSUInteger page = (NSUInteger)(self.ModelRect.count / self.rowsPerPage);
    if (self.ModelRect.count % self.rowsPerPage > 0 && self.ModelRect.count > self.rowsPerPage) {
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
    if (!tableview.tableFooterView) {
        tableview.tableFooterView = [[UIView alloc] init];
    }
    tableview.delegate=self;
    tableview.dataSource=self;
    _xy_tableView = tableview;
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
        MJRefreshBackNormalFooter* footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(xy_refreshFooter)];
        tableview.mj_footer = footer;
        [footer setTitle:@"" forState:MJRefreshStateIdle];
        [footer setTitle:@"" forState:MJRefreshStateNoMoreData];
        [footer setTitle:@"" forState:MJRefreshStatePulling];
        [footer setTitle:@"" forState:MJRefreshStateRefreshing];
        [footer setTitle:@"" forState:MJRefreshStateWillRefresh];
        footer.stateLabel.hidden = YES;
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
        return;
    }
    self.isHeaderTriggerLastToken = YES;
    __weak typeof(self) weakself = self;
    [self refresh:self.xy_tableView page:0 complete:^(NSArray * _Nullable modelRect) {
        if (weakself.isHeaderTriggerLastToken) {
            if (modelRect) {
                [weakself.ModelRect removeAllObjects];
                if (weakself.ModelRect.count>0 && [weakself.ModelRect.firstObject isKindOfClass:[XYSectionModel class]]) weakself.xy_isRect = YES;
                [weakself.ModelRect addObjectsFromArray:modelRect];
                [weakself.xy_tableView reloadData];
            }
            [weakself endRefreshing];
        }
        [weakself.xy_tableView.mj_header endRefreshing];
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
    NSUInteger completePage = self.ModelRect.count / self.rowsPerPage;
    NSUInteger unCompleteNum = self.ModelRect.count % self.rowsPerPage;
    self.isHeaderTriggerLastToken = NO;
    __weak typeof(self) weakself = self;
    [self refresh:self.xy_tableView page:completePage complete:^(NSArray<NSDictionary *> * _Nullable modelRect) {
        if (!weakself.isHeaderTriggerLastToken) {
            if (modelRect) {
                [weakself.ModelRect removeObjectsInRange:NSMakeRange(weakself.ModelRect.count - unCompleteNum, unCompleteNum)];
                [weakself.ModelRect addObjectsFromArray:modelRect];
                [weakself.xy_tableView reloadData];
            }
            [weakself endRefreshing];
        }
        [weakself.xy_tableView.mj_footer endRefreshing];
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
        DLogVerbose(@"\n没有注册这种cell， 现在通过 alloc init 创建\n%@",data);
        cell = [[data.cls alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identi];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.xyModelDelegate    = self;
    cell.xyModel     = data;
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XYRowModel*data = self.xy_isRect?((XYSectionModel*)self.ModelRect[indexPath.section]).rows[indexPath.row]:self.ModelRect[indexPath.row];
    UITableViewCell* cell = [self getReuseCellWithModel:data tableview:tableView];
    data.index = indexPath;
    return cell;
}

#pragma mark - cell height

-(CGFloat)getReuseCellHeightWithModel:(XYRowModel*)data tableview:(UITableView*)tableView index:(NSIndexPath*)index{
    __block CGFloat height = 0;
    @try {
        if (data.height >= 0 && data.height != UITableViewAutomaticDimension) {
            height = data.height;
        }else{
            height=[data.cls xyHeightWithModel:data width:tableView.frame.size.width];
            if (height == -2) {
                UITableViewCell* cell = self.cellForCaculating[data.identifier];
                if (!cell) {
                    cell = [self getReuseCellWithModel:data tableview:tableView];
                    self.cellForCaculating[data.identifier] = cell;
                }else{
                    cell.xyModel = data;
                }
                height = [cell.contentView autoLayoutHeightWithWidth:tableView.frame.size.width];
                data.height = height;
            }else if (height == -1){
                height = UITableViewAutomaticDimension;
            }
        }
    } @catch (NSException *exception) {
        DLogError(@"%@",exception);
        height = 100;
    }
    return height;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    XYRowModel*data = self.xy_isRect?((XYSectionModel*)self.ModelRect[indexPath.section]).rows[indexPath.row]:self.ModelRect[indexPath.row];
    if (data) {
        return [self getReuseCellHeightWithModel:data tableview:tableView index:indexPath];
    }
    return 50;
}

#pragma mark - header

-(UITableViewHeaderFooterView*)getReuseHeaderWithModel:(XYRowModel*)data tableview:(UITableView*)tableView{
    UITableViewHeaderFooterView* cell = [tableView dequeueReusableHeaderFooterViewWithIdentifier:data.identifier];
    if (!cell) {
//        DLogVerbose(@"\n没有注册这种 header， 现在通过 alloc init 创建\n%@",data);
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
        DLogError(@"%@",exception);
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
//        DLogVerbose(@"\n没有注册这种 footet， 现在通过 alloc init 创建\n%@",data);
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
        DLogError(@"%@",exception);
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
