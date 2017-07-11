//
//  DKAssetGroupDetailVC.m
//  DKImagePickerControllerDemo_OC
//
//  Created by 赵铭 on 2017/6/27.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKAssetGroupDetailVC.h"
#import "DKImageResource.h"
#import "DKImagePickerController.h"
#import "DKImageManager.h"
#import "DKGroupDataManager.h"
#import "DKImagePickerControllerDefaultUIDelegate.h"
#import "DKAsset.h"
#import "DKAssetGroup.h"
#import "DKAssetGroupDetailBaseCell.h"
#import "DKAssetGroupDetailImageCell.h"
#import "DKAssetGroupDetailVideoCell.h"
#import "DKAssetGroupListVC.h"
#import "DKAssetGroupDetailCameraCell.h"
#import "DKPopoverViewController.h"
#import "DKPermissionView.h"
@implementation UICollectionView(DKExtension)

- (NSArray <NSIndexPath *>*)indexPathsForElementsInRect:(CGRect)rect
                                            hidesCamera:(BOOL)hidesCamera{
    NSArray * allLayoutAttributes = [self.collectionViewLayout layoutAttributesForElementsInRect:rect];
    NSMutableArray * tem = @[].mutableCopy;
    if (hidesCamera) {
        for (UICollectionViewLayoutAttributes * la in allLayoutAttributes) {
            [tem addObject:la.indexPath];
        }
        return tem;
    }else{
        for (UICollectionViewLayoutAttributes * la in allLayoutAttributes) {
            if (la.indexPath.item == 0) {
                
            }else{
                NSIndexPath * idx = [NSIndexPath indexPathForRow:la.indexPath.item - 1 inSection:la.indexPath.section];
                [tem addObject:idx];

            }
        }
        return tem;
    }
}

@end


@interface DKAssetGroupDetailVC ()<DKGroupDataManagerObserver>
@property (nonatomic, strong) UIButton * selectGroupButton;
@property (nonatomic, copy) NSString * selectedGroupId;
@property (nonatomic, assign) BOOL hidesCamera;
@property (nonatomic, strong) UIView * footerView;
@property (nonatomic, assign) CGSize currentViewSize;
@property (nonatomic, strong) NSMutableSet * registeredCellIdentifiers;
@property (nonatomic, assign) CGSize thumbnailSize;
@property (nonatomic, assign) CGRect previousPreheatRect;
@property (nonatomic, strong) DKAssetGroupListVC * groupListVC;
@end

@implementation DKAssetGroupDetailVC

- (id)init{
    if (self = [super init]) {
        _hidesCamera = NO;
        _thumbnailSize = CGSizeZero;
        _registeredCellIdentifiers = [NSMutableSet new];
        _previousPreheatRect = CGRectZero;
        
    }
    return self;
}

- (void)viewWillLayoutSubviews{
    [super viewWillLayoutSubviews];
    if (CGSizeEqualToSize(_currentViewSize, self.view.bounds.size)) {
        return;
    }else{
        _currentViewSize = self.view.bounds.size;
    }
    [self.collectionView.collectionViewLayout invalidateLayout];
    
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    if (self.footerView) {
        self.footerView.frame = CGRectMake(0, self.view.bounds.size.height - self.footerView.bounds.size.height, self.view.bounds.size.width, self.footerView.bounds.size.height);
        
        self.collectionView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - self.footerView.bounds.size.height);
    }else{
        self.collectionView.frame = self.view.bounds;
    }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    UICollectionViewLayout * layout = [self.imagePickerController.UIDelegate layoutForImagePickerController:self.imagePickerController];
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
    self.collectionView.backgroundColor = [self.imagePickerController.UIDelegate imagePickerControllerCollectionViewBackgroundColor];
    self.collectionView.allowsMultipleSelection = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    self.footerView = [self.imagePickerController.UIDelegate imagePickerControllerFooterView:self.imagePickerController];
    if (self.footerView) {
        [self.view addSubview:self.footerView];
    }
    self.hidesCamera = self.imagePickerController.sourceType == DKImagePickerControllerSourcePhotoType;
    [self checkPhotoPermission];
    // Do any additional setup after loading the view.
}

- (UIButton *)selectGroupButton{
    if (!_selectGroupButton) {
        _selectGroupButton = [UIButton new];
        UIColor * globalTitleColor = [UINavigationBar appearance].titleTextAttributes[NSForegroundColorAttributeName];
        [_selectGroupButton setTitleColor:globalTitleColor?:[UIColor blackColor] forState:UIControlStateNormal];
        
        UIFont * globalTitleFont =  [UINavigationBar appearance].titleTextAttributes[NSFontAttributeName];
        
        _selectGroupButton.titleLabel.font = globalTitleFont?:[UIFont boldSystemFontOfSize:18];
        [_selectGroupButton addTarget:self action:@selector(showGroupSelector) forControlEvents:UIControlEventTouchUpInside];
    }
    return _selectGroupButton;
}

- (void)showGroupSelector{
    [DKPopoverViewController popoverViewController:self.groupListVC fromView:self.selectGroupButton];
}

- (void)checkPhotoPermission{
     [DKImageManager checkPhotoPermissionWithHandle:^(BOOL granted) {
         granted ? [self setup] : [self photoDenied];
     }];
}

- (void)photoDenied{
   [self.view addSubview: [DKPermissionView permissionView:DKImagePickerControllerSourcePhotoType]];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.collectionView.hidden = YES;
}

- (void)setup{
    [self resetCachedAssets];
    [[[DKImageManager shareInstance] groupDataManager] addObserver:self];
    __weak typeof(self) weakSelf = self;
    self.groupListVC = [[DKAssetGroupListVC alloc] initWithSelectedGroupDidChangeBlock:^(NSString *groupId) {
        __strong typeof (self) strongSelf = weakSelf;
        [strongSelf selectAssetGroup:groupId];
    } defaultAssetGroup:self.imagePickerController.defaultAssetGroup];
    [self.groupListVC loadGroups];
}

- (void)selectAssetGroup:(NSString * )groupId{
    if ([self.selectedGroupId  isEqualToString:groupId]) {
        [self updateTitleView];
        return;
    }
    self.selectedGroupId = groupId;
    [self updateTitleView];
    [self.collectionView reloadData];

    dispatch_async(dispatch_get_main_queue(), ^{
    });
}


- (void)updateTitleView{
    
    DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:self.selectedGroupId];
    self.title = group.groupName;
    NSInteger groupsCount = [[[[DKImageManager shareInstance] groupDataManager] groupIds] count];
    [self.selectGroupButton setTitle:[NSString stringWithFormat:@"%@%@", group.groupName, groupsCount > 1 ? @"\u25be" : @""] forState:UIControlStateNormal];
    [self.selectGroupButton sizeToFit];
    self.selectGroupButton.enabled = groupsCount > 1;
    self.navigationItem.titleView = self.selectGroupButton;

}

- (DKAsset *)fetchAsset:(NSInteger)index{
    
    if (!self.hidesCamera && index == 0) {
        return nil;
    }
    NSInteger assetIndex = index - (self.hidesCamera ? 0 : 1);
    DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:self.selectedGroupId];
    DKAsset * asset = [[[DKImageManager shareInstance] groupDataManager] fetchAsset:group index:assetIndex];
    return asset;
    
}

- (DKAssetGroupDetailBaseCell *)dequeueReusableCameraCellForIndexPath:(NSIndexPath *)indexPath{
    Class cellCls = [self.imagePickerController.UIDelegate imagePickerControllerCollectionCameraCell];
    NSString * cellId = [cellCls performSelector:@selector(cellReuseIdentifier)];
    [self registerCellifNeededWithCellClass:cellCls cellReuseIdentifier:cellId];
    
    DKAssetGroupDetailBaseCell * cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    return cell;
    
}

- (DKAssetGroupDetailBaseCell *)dequeueReusableCellForIndexPath:(NSIndexPath *)indexPath{
    DKAsset * asset = [self fetchAsset:indexPath.item];
    Class cellCls;
//    if ([cellCls respondsToSelector:@selector(index)]) {
//        
//    }
//    if ([cellCls ]) {
//        
//    }
    NSString * cellId;
    if (asset.isVideo) {
//        cellCls = [DKAssetGroupDetailVideoCell class];
//        cellId = [DKAssetGroupDetailVideoCell cellReuseIdentifier];
        
        cellCls = [self.imagePickerController.UIDelegate imagePickerControllerCollectionVideoCell];//[DKAssetGroupDetailVideoCell class];
        cellId = [cellCls performSelector:@selector(cellReuseIdentifier)];//[DKAssetGroupDetailVideoCell cellReuseIdentifier];

    }else{
//        cellCls = [DKAssetGroupDetailImageCell class];
//        cellId = [DKAssetGroupDetailImageCell cellReuseIdentifier];
        cellCls = [self.imagePickerController.UIDelegate imagePickerControllerCollectionImageCell];//[DKAssetGroupDetailImageCell class];
        cellId = [cellCls performSelector:@selector(cellReuseIdentifier)];//[DKAssetGroupDetailImageCell cellReuseIdentifier];
    }
    
    
    [self registerCellifNeededWithCellClass:cellCls cellReuseIdentifier:cellId];
    DKAssetGroupDetailBaseCell * cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:cellId forIndexPath:indexPath];
    [self setupAssetCell:cell indexPath:indexPath asset:asset];
    return cell;
}
- (void)registerCellifNeededWithCellClass:(Class)cellClass cellReuseIdentifier:(NSString *)cellReuseIdentifier{
    
    if (![self.registeredCellIdentifiers containsObject:cellReuseIdentifier]) {
        [self.collectionView registerClass:cellClass forCellWithReuseIdentifier:cellReuseIdentifier];
        [self.registeredCellIdentifiers addObject:cellReuseIdentifier];
    }
    
}

- (BOOL)isCameraCell:(NSIndexPath * )indexPath{
    return indexPath.row == 0 && !self.hidesCamera;
}
- (void)resetCachedAssets{
    [[DKImageManager shareInstance] stopCachingForAllAssets];
    self.previousPreheatRect = CGRectZero;
}
- (void)setupAssetCell:(DKAssetGroupDetailBaseCell *)cell
             indexPath:(NSIndexPath *)indexPath
                 asset:(DKAsset *)asset{
    cell.asset = asset;
    NSInteger tag = indexPath.row + 1;
    cell.tag = tag;
    
    if (CGSizeEqualToSize(self.thumbnailSize, CGSizeZero)) {
        CGSize size = [self.collectionView.collectionViewLayout  layoutAttributesForItemAtIndexPath:indexPath].size;
        self.thumbnailSize = [DKImageManager toPixel:size];
    }
    
    [asset fetchImageWithSize:self.thumbnailSize options:nil contentMode:PHImageContentModeAspectFill completeBlock:^(UIImage *image, NSDictionary *info) {
        if (cell.tag == tag) {
            cell.thumbnailImage = image;
        }
    }];
    
    NSInteger result = [self.imagePickerController.selectedAssets indexOfObject:asset] ;
    if ( result == NSNotFound) {
        cell.selected = NO;
        [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    }else{
        cell.selected = YES;
        cell.index = [self.imagePickerController.selectedAssets indexOfObject:asset];
        [self.collectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
        
    }
}


#pragma mark -- UICollectionViewDelegate, UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if (!self.selectedGroupId) {
        return 0;
    }
    DKAssetGroup * group = [[[DKImageManager shareInstance] groupDataManager] fetchGroupWithGroupId:self.selectedGroupId];
    NSInteger count = group.totalCount + (self.hidesCamera ? 0 : 1);
    return count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DKAssetGroupDetailBaseCell * cell;
    if ([self isCameraCell:indexPath]) {
        cell = [self dequeueReusableCameraCellForIndexPath:indexPath];
    }else{
        cell = [self dequeueReusableCellForIndexPath:indexPath];
    }
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    DKAsset * firstSelectAsset = self.imagePickerController.selectedAssets.firstObject;
    if (firstSelectAsset) {
        DKAssetGroupDetailBaseCell * cell = (DKAssetGroupDetailBaseCell *)[collectionView cellForItemAtIndexPath:indexPath];
        DKAsset * selected = cell.asset;
        if (!self.imagePickerController.allowMultipleTypes && firstSelectAsset.isVideo != selected.isVideo) {
            
           UIAlertController * alert = [UIAlertController alertControllerWithTitle:[DKImageLocalizedString localizedStringForKey:@"selectPhotosOrVideos"] message:[DKImageLocalizedString localizedStringForKey:@"selectPhotosOrVideosError"] preferredStyle:UIAlertControllerStyleAlert];
            
           [alert addAction:[UIAlertAction actionWithTitle:[DKImageLocalizedString localizedStringForKey:@"ok"] style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
               
           }]];
           [self.imagePickerController presentViewController:alert animated:YES completion:nil];
           return NO;
        }
    }
    BOOL shouldSelect = self.imagePickerController.selectedAssets.count < self.imagePickerController.maxSelectableCount;
    if (!shouldSelect) {
        [self.imagePickerController.UIDelegate imagePickerControllerDidReachMaxLimit:self.imagePickerController];
    }
    return shouldSelect;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isCameraCell:indexPath]) {
        NSLog(@"%@", [[[DKImageManager shareInstance] groupDataManager] observers]);
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            [self.imagePickerController presentCamera];
        }
    }else{
       
        DKAsset * selectedAsset =  ((DKAssetGroupDetailBaseCell *)[collectionView cellForItemAtIndexPath:indexPath]).asset;
        [self.imagePickerController selectImage:selectedAsset];
        ((DKAssetGroupDetailBaseCell *)[collectionView cellForItemAtIndexPath:indexPath]).index = self.imagePickerController.selectedAssets.count - 1;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath{
    if ([self isCameraCell:indexPath]) {
        [self collectionView:collectionView didSelectItemAtIndexPath:indexPath];
        return;
    }
    
    DKAsset * removedAsset = ((DKAssetGroupDetailBaseCell *) [collectionView cellForItemAtIndexPath:indexPath]).asset;
    if (!removedAsset) {
        return;
    }
    NSInteger removedIndex= [self.imagePickerController.selectedAssets indexOfObject:removedAsset];
    NSArray <NSIndexPath *> * indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems;
    NSArray <NSIndexPath *> * indexPathsForVisibleItems = collectionView.indexPathsForVisibleItems;
    NSMutableSet *set1 = [NSMutableSet setWithArray: indexPathsForVisibleItems];
    NSSet *set2 = [NSSet setWithArray: indexPathsForSelectedItems];
    [set1 intersectSet: set2];
    NSArray *resultArray = [set1 allObjects];
    for (NSIndexPath * selectedIndexPath in resultArray) {
       DKAssetGroupDetailBaseCell * selectedCell = (DKAssetGroupDetailBaseCell *)[collectionView cellForItemAtIndexPath:selectedIndexPath];
        DKAsset * selectedCellAsset = selectedCell.asset;
        NSInteger selectedIndex = [self.imagePickerController.selectedAssets indexOfObject:selectedCellAsset];
        if (selectedIndex > removedIndex) {
            selectedCell.index = selectedCell.index - 1;
        }
    }
    [self.imagePickerController deselectImage:removedAsset];
}

#pragma mark -- DKGroupDataManagerObserver
- (void)groupDidUpdate:(NSString *)groupId{
    if ([self.selectedGroupId isEqualToString:groupId]) {
        [self updateTitleView];
    }
}


- (void)group:(NSString *)groupId didRemoveAssets:(NSArray<DKAsset *> *)assets {
    NSMutableArray * tem = @[].mutableCopy;
    for (DKAsset * selectedAsset in self.imagePickerController.selectedAssets) {
        for (DKAsset * removedAsset in assets) {
            if ([selectedAsset isEqual:removedAsset]) {
                [tem addObject:selectedAsset];
            }
        }
    }
    
    for (DKAsset * asset in tem) {
        [self.imagePickerController deselectImage:asset];
    }
}


- (void)groupDidUpdateComplete:(NSString *)groupId{
    if ([self.selectedGroupId isEqualToString:groupId]) {
        [self resetCachedAssets];
        [self.collectionView reloadData];
    }
    
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
