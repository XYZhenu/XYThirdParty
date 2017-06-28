//
//  ImageLoaderSaveVC.m
//  XYThirdParty
//
//  Created by xyzhenu on 2017/6/28.
//  Copyright © 2017年 xyzhenu. All rights reserved.
//

#import "ImageLoaderSaveVC.h"
#import "ImageUploader.h"
#import "XYRichTextVC.h"
@interface ImageLoaderSaveVC ()<XYOperateDelegate>
@property(nonatomic,strong)NSOperationQueue* operqueue;
@property(nonatomic,strong)NSArray<ImageUploader*>*loaders;
@end

@implementation ImageLoaderSaveVC

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemPlay target:self action:@selector(startAll)];
    
    
    self.operqueue = [[NSOperationQueue alloc] init];
    self.operqueue.maxConcurrentOperationCount = 2;
    self.operqueue.name = @"rich_text_uploader";
    self.loaders = [ImageUploader instancesOfGroup:@"test"];
    [self.tableView reloadData];
    
}
-(void)startAll{
    [self.operqueue addOperations:self.loaders waitUntilFinished:NO];
}
-(void)uploaderComplete:(ImageUploader *)uploader error:(BOOL)error{
    [self.tableView reloadData];
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return self.loaders.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.loaders[indexPath.row].identifier;
    cell.detailTextLabel.text = self.loaders[indexPath.row].msg.uploadedUrl;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath{
    [self.operqueue addOperation:self.loaders[indexPath.row]];
}
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
