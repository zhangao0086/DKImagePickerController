//
//  DKAssetGroupListVC.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/29.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAssetGroupListVC.h"
#import "DKImageResource.h"
#import "DKImageManager.h"
#import "DKGroupDataManager.h"
#import "DKAssetGroup.h"
#import "DKPopoverViewController.h"
static NSString * DKImageGroupCellIdentifier = @"DKImageGroupCellIdentifier";

@interface DKAssetGroupSeparator : UIView


@end

@implementation DKAssetGroupSeparator
- (UIColor*)backgroundColor{
    return [super backgroundColor];
}
- (void)setBackgroundColor:(UIColor *)backgroundColor{
    if (backgroundColor != [UIColor clearColor]) {
        super.backgroundColor = backgroundColor;
    }
}
@end

@interface DKAssetGroupCell : UITableViewCell
@property (nonatomic, strong) UIImageView * thumbnailImageView;
@property (nonatomic, strong) UILabel * groupNameLabel;
@property (nonatomic, strong) UILabel * totalCountLabel;
@property (nonatomic, strong) UIView * customSelectedBackgroundView;
@property (nonatomic, strong) DKAssetGroupSeparator * customSeparator;
@end

@implementation DKAssetGroupCell

- (UIImageView *)thumbnailImageView{
    if (!_thumbnailImageView) {
        _thumbnailImageView = [UIImageView new];
        _thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
        _thumbnailImageView.clipsToBounds = YES;
    }
    return _thumbnailImageView;
}

- (UILabel *)groupNameLabel{
    if (!_groupNameLabel) {
        _groupNameLabel = [UILabel new];
        _groupNameLabel.font = [UIFont boldSystemFontOfSize:13];
    }
    return _groupNameLabel;
}

- (UILabel *)totalCountLabel{
    if (!_totalCountLabel) {
        _totalCountLabel = [UILabel new];
        _totalCountLabel.font = [UIFont systemFontOfSize:10];
        _totalCountLabel.textColor = [UIColor grayColor];
    }
    return _totalCountLabel;
}

- (UIView *)customSelectedBackgroundView{
    if (!_customSelectedBackgroundView) {
        _customSelectedBackgroundView = [UIView new];
        UIImageView * selectedFlag = [[UIImageView alloc] initWithImage:[DKImageResource blueTickImage]];
        selectedFlag.frame = CGRectMake(_customSelectedBackgroundView.bounds.size.width - selectedFlag.bounds.size.width - 20,(_customSelectedBackgroundView.bounds.size.width - selectedFlag.bounds.size.width) / 2, selectedFlag.bounds.size.width, selectedFlag.bounds.size.height);
        selectedFlag.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin;
        [_customSelectedBackgroundView addSubview:selectedFlag];
    }
    
    return _customSelectedBackgroundView;
}

- (DKAssetGroupSeparator *)customSeparator{
    if (!_customSeparator ) {
        _customSeparator = [[DKAssetGroupSeparator alloc] initWithFrame:CGRectMake(10, self.bounds.size.height - 1, self.bounds.size.width, 0.5)];
        _customSeparator.backgroundColor = [UIColor lightGrayColor];
        _customSeparator.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _customSeparator;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectedBackgroundView = self.customSelectedBackgroundView;
        [self.contentView addSubview:self.thumbnailImageView];
        [self.contentView addSubview:self.groupNameLabel];
        [self.contentView addSubview:self.totalCountLabel];
        [self addSubview:self.customSeparator];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    CGFloat imageViewY = 10.0;
    CGFloat imageViewHeight = self.contentView.bounds.size.height - 2*imageViewY;
    self.thumbnailImageView.frame = CGRectMake(imageViewY, imageViewY, imageViewHeight, imageViewHeight);
    
    self.groupNameLabel.frame = CGRectMake(CGRectGetMaxX(self.thumbnailImageView.frame) + 10, CGRectGetMinY(self.thumbnailImageView.frame) + 5 , 200, 20);
    
    self.totalCountLabel.frame = CGRectMake(CGRectGetMinX(self.groupNameLabel.frame), CGRectGetMaxY(self.thumbnailImageView.frame) - 20, 200, 20);
    
}

@end





@interface DKAssetGroupListVC ()
@property (nonatomic, copy) NSArray <NSString *>*groups;
@property (nonatomic, copy) NSString * selectedGroup;

@property (nonatomic, strong)PHImageRequestOptions *groupThumbnailRequestOptions;
@end

@implementation DKAssetGroupListVC
- (instancetype)initWithSelectedGroupDidChangeBlock:(void(^)(NSString * groupId))selectedGroupDidChangeBlock
                                  defaultAssetGroup:(PHAssetCollectionSubtype)defaultAssetGroup{
    if (self = [super initWithStyle:UITableViewStylePlain]) {
        self.defaultAssetGroup = defaultAssetGroup;
        self.selectedGroupDidChangeBlock = selectedGroupDidChangeBlock;
    }
    return self;
}

- (PHImageRequestOptions *)groupThumbnailRequestOptions{
    if (!_groupThumbnailRequestOptions) {
        _groupThumbnailRequestOptions = [PHImageRequestOptions new];
        _groupThumbnailRequestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
        _groupThumbnailRequestOptions.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    return _groupThumbnailRequestOptions;
}
- (CGSize)preferredContentSize{
    if (self.groups.count > 0) {
        return CGSizeMake(UIViewNoIntrinsicMetric, _groups.count * self.tableView.rowHeight);
    }else{
        return [super preferredContentSize];
    }
}
- (void)setPreferredContentSize:(CGSize)preferredContentSize{
    super.preferredContentSize = preferredContentSize;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self .tableView registerClass:[DKAssetGroupCell class] forCellReuseIdentifier:DKImageGroupCellIdentifier];
    self.tableView.rowHeight = 70;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}
- (void)loadGroups{
    
    __weak typeof(self) weakSelf = self;
    [[[DKImageManager shareInstance] groupDataManager] fetchGroupsWithCompleteBlock:^(NSArray<NSString *> *groupIds, NSError *error) {
        __strong typeof(self) strongSelf = weakSelf;
        strongSelf.groups = groupIds;
        strongSelf.selectedGroup = [strongSelf defaultAssetGroupOfAppropriate];
        if (strongSelf.selectedGroup) {
            NSInteger row = [strongSelf.groups indexOfObject:strongSelf.selectedGroup];
            
            [strongSelf.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
            
        }
        if (strongSelf.selectedGroupDidChangeBlock) {
            strongSelf.selectedGroupDidChangeBlock(strongSelf.selectedGroup);
        }
    }];
}

- (NSString *)defaultAssetGroupOfAppropriate{
    if (!self.groups) {
        return nil;
    }
    for (NSString * groupId in self.groups) {
       DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:groupId
         ];
        if (self.defaultAssetGroup == group.originalCollection.assetCollectionSubtype) {
            return groupId;
        }
    
    }
    return self.groups.firstObject;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.groups.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DKAssetGroupCell *cell = [tableView dequeueReusableCellWithIdentifier:DKImageGroupCellIdentifier forIndexPath:indexPath];
    
    DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:self.groups[indexPath.row]];
    cell.groupNameLabel.text = group.groupName;
    NSInteger tag = indexPath.row + 1;
    cell.tag = tag;
    
    if (group.totalCount == 0) {
        cell.thumbnailImageView.image= [DKImageResource emptyAlbumIcon];
    }else{
        [[[DKImageManager shareInstance] groupDataManager] fetchGroupThumbnailForGroup:group.groupId size:CGSizeMake(tableView.rowHeight, tableView.rowHeight) options:self.groupThumbnailRequestOptions completeBlock:^(UIImage *image, NSDictionary *info) {
            if (cell.tag == tag) {
                cell.thumbnailImageView.image = image;
            }
        }];
    }
    
    cell.totalCountLabel.text = [NSString stringWithFormat:@"%ld", (long)group.totalCount];
    return cell;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [DKPopoverViewController dismissPopoverViewController];
    self.selectedGroup = _groups[indexPath.row];
    self.selectedGroupDidChangeBlock(self.selectedGroup);
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
