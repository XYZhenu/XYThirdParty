//
//  XYTableViewController.h
//  XYCategories
//
//  Created by xyzhenu on 2017/6/9.
//  Copyright © 2017年 xieyan. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN;

@interface XYRowModel : NSObject
@property (nonatomic,assign)Class cls;
@property (nonatomic,strong)NSString* identifier;
@property (nonatomic,strong)NSIndexPath* index;
@property (nonatomic,assign)BOOL selected;
@property (nonatomic,assign)CGFloat height;
@property (nonatomic,assign)CGFloat _width;
@property (nonatomic,strong)NSDictionary<NSString*,id>* message;
@property (nonatomic,strong,nullable)id model;
-(instancetype)initCls:(Class)cls msg:(NSDictionary<NSString*,id>*)msg;
-(instancetype)initCls:(Class)cls model:(id)model;
@end

@interface XYSectionModel : NSObject
@property (nonatomic,strong)NSMutableArray<XYRowModel*>*rows;
@property (nonatomic,strong)NSDictionary<NSString*,id>*message;
@property (nonatomic,strong)XYRowModel*header;
@property (nonatomic,strong)XYRowModel*footer;
-(instancetype)initRows:(NSArray<XYRowModel*>*)rows msg:(nullable NSDictionary<NSString*,id>*)msg;
-(instancetype)initOCRows:(NSMutableArray*)rows msg:(nullable NSDictionary<NSString*,id>*)msg;
@end

@protocol XYModelDelegate <NSObject>
-(void)XYModelResponse:(XYRowModel* )model;
@end

@interface UITableViewCell (XYRowModel)
@property(nonatomic,weak,nullable) id<XYModelDelegate>xyModelDelegate;
@property(nonatomic,strong) XYRowModel* xyModel;
-(void)xyModelSet:(XYRowModel*)model;
+(CGFloat)xyHeightWithModel:(XYRowModel*)model width:(CGFloat)width;
@end

@interface UITableViewHeaderFooterView (XYRowModel)
@property(nonatomic,weak,nullable) id<XYModelDelegate>xyModelDelegate;
@property(nonatomic,strong) XYRowModel* xyModel;
-(void)xyModelSet:(XYRowModel*)model;
+(CGFloat)xyHeightWithModel:(XYRowModel*)model width:(CGFloat)width;
@end

@interface XYTableViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,XYModelDelegate>

@property(nonatomic,strong)NSMutableArray*ModelRect;
@property(nonatomic,strong)NSMutableArray*operateRect;
-(NSUInteger)currentItemCount;
@property(nonatomic,assign)NSUInteger rowsPerPage;//default 10
@property(nonatomic,assign,readonly)NSUInteger currentPage;

-(void)bindTableView:(UITableView*)tableview isRect:(BOOL)isrect;
-(void)bindTableView:(UITableView*)tableview;
-(void)bindRefreshHeader:(UITableView*)tableview withText:(BOOL)withText;
-(void)bindRefreshFooter:(UITableView*)tableview;

@property(nonatomic,assign)BOOL isRefreshing;
-(void)refreshHeaderSilently:(BOOL)silently;
-(void)refreshFooterSilently:(BOOL)silently;
@property(nonatomic,assign)BOOL shouldAutoLoadMore;
-(void)refresh:(UITableView*)tableView page:(NSUInteger)page complete:(void(^)(NSArray* _Nullable modelRect))complete;

-(void)XYModelResponse:(XYRowModel* )model;

@end

NS_ASSUME_NONNULL_END;

