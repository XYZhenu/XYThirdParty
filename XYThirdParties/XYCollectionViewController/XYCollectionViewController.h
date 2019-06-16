//
//  XYCollectionViewController.h
//  AFNetworking
//
//  Created by xyzhenu on 2019/5/29.
//

#import <UIKit/UIKit.h>
#import "XYTableViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface UICollectionReusableView (XYRowModel)
@property(nonatomic,weak,nullable) id<XYModelDelegate>xyModelDelegate;
@property(nonatomic,strong) XYRowModel* xyModel;
-(void)xyModelSet:(XYRowModel*)model;
+(CGSize)xySizeWithModel:(XYRowModel*)model maxWidth:(CGFloat)width;
@end

@interface XYCollectionViewController : UIViewController <UICollectionViewDelegateFlowLayout,UICollectionViewDataSource,XYModelDelegate>
@property(nonatomic,strong)UICollectionViewFlowLayout* flowLayout;//Lazy load;

@property(nonatomic,assign)BOOL alwaysHideTabbar;//default NO;

@property(nonatomic,strong)NSMutableArray*ModelRect;
@property(nonatomic,strong)NSMutableArray*operateRect;
-(NSUInteger)currentItemCount;
@property(nonatomic,assign)NSUInteger rowsPerPage;//default 10
@property(nonatomic,assign,readonly)NSUInteger currentPage;

-(void)bindCollectionView:(UICollectionView*)collectionView isRect:(BOOL)isrect;
-(void)bindCollectionView:(UICollectionView*)collectionView;
-(void)bindRefreshHeader:(UICollectionView*)collectionView withText:(BOOL)withText;
-(void)bindRefreshFooter:(UICollectionView*)collectionView;

@property(nonatomic,assign)BOOL isRefreshing;
-(void)endRefreshing;
-(void)refreshHeaderSilently:(BOOL)silently;
-(void)refreshFooterSilently:(BOOL)silently;
@property(nonatomic,assign)BOOL shouldAutoLoadMore;
-(void)refresh:(UICollectionView*)collectionView page:(NSUInteger)page complete:(void(^)(NSArray* _Nullable modelRect, BOOL finished))complete;

-(void)XYModelResponse:(XYRowModel* )model;

@end

NS_ASSUME_NONNULL_END
