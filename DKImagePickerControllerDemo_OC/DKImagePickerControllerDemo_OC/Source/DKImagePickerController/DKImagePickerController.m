//
//  DKImagePickerViewController.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/26.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickerController.h"
#import "DKImagePickerControllerDefaultUIDelegate.h"
#import "DKImageManager.h"
#import "DKAssetGroupDetailVC.h"
#import "DKGroupDataManager.h"
#import "DKAsset.h"
@interface DKImagePickerController ()
@property (nonatomic, assign) BOOL hasInitialized;
@property (nonatomic, strong) PHFetchOptions * assetFetchOptions;
@end

@implementation DKImagePickerController
- (void)done{
    if (self.presentingViewController) {
        [self.presentingViewController dismissViewControllerAnimated:YES completion:^{
            if (self.didSelectAssets) {
                self.didSelectAssets(self.selectedAssets);
            }
        }];
    }
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if (!_hasInitialized) {
        _hasInitialized = YES;
        if (self.sourceType == DKImagePickerControllerSourceCameraType) {
            self.navigationBarHidden = YES;
            UIViewController * camera = [self createCamera];
            if ([camera isKindOfClass:[UINavigationController  class]]) {
                [self presentViewController:camera animated:YES completion:nil];
                [self setViewControllers:@[]];
            }else{
                [self setViewControllers:@[camera]];
            }
            
        }else{
            self.navigationBarHidden = NO;
            DKAssetGroupDetailVC * vc = [[DKAssetGroupDetailVC alloc] init];
            vc.imagePickerController = self;
            [self.UIDelegate prepareLayout:self vc:vc];
            [self updateCancelButtonForVC:vc];
            self.viewControllers = @[vc];
            if (self.defaultSelectedAssets.count > 0) {
                [self.UIDelegate imagePickerController:self didSelectAssets:self.defaultSelectedAssets];
            }
        }
    }
}

- (void)updateCancelButtonForVC:(UIViewController *)vc{
    if (self.showsCancelButton) {
        [self.UIDelegate imagePickerController:self showsCancelButtonForVC:vc];
    }else{
        [self.UIDelegate imagePickerController:self hidesCancelButtonForVC:vc];
    }
}

- (void)setShowsCancelButton:(BOOL)showsCancelButton{
        _showsCancelButton = showsCancelButton;
        UIViewController * vc = [[self viewControllers] firstObject];
        [self updateCancelButtonForVC:vc];
}

- (id)init{
    if (self = [super init]) {
        _showsCancelButton = NO;
        _sourceType = DKImagePickerControllerSourceBothType;
        _hasInitialized = false;
        _singleSelect = NO;
        _maxSelectableCount = 999;
        self.assetGroupTypes = @[@(PHAssetCollectionSubtypeSmartAlbumUserLibrary),
                              @(PHAssetCollectionSubtypeSmartAlbumFavorites),
                              @(PHAssetCollectionSubtypeAlbumRegular)];
        self.showsEmptyAlbums = YES;
        self.assetType = DKImagePickerControllerAssetAllAssetsType;
        _allowMultipleTypes = YES;
        self.autoDownloadWhenAssetIsInCloud = YES;
        _allowsLandscape = NO;
        _selectedAssets = @[].mutableCopy;
        
        UIViewController * rootVC = [UIViewController new];
        self.viewControllers = @[rootVC];
        self.preferredContentSize = CGSizeMake(680, 600);
        rootVC.navigationItem.hidesBackButton = YES;
        
        [[DKImageManager shareInstance] groupDataManager].assetGroupTypes = self.assetGroupTypes;
        [[DKImageManager shareInstance] groupDataManager].assetFetchOptions = [self createAssetFetchOptions];
        [[DKImageManager shareInstance] groupDataManager].showsEmptyAlbums = self.showsEmptyAlbums;
        [DKImageManager shareInstance].autoDownloadWhenAssetIsInCloud = self.autoDownloadWhenAssetIsInCloud ;
        
    }
    return self;
}
- (PHFetchOptions *)assetFetchOptions{
    if (!_assetFetchOptions) {
        _assetFetchOptions = [PHFetchOptions new];
    }
    return _assetFetchOptions;
}
- (void)setAssetGroupTypes:(NSArray<NSNumber *> *)assetGroupTypes{
    if (_assetGroupTypes != assetGroupTypes) {
        _assetGroupTypes = assetGroupTypes;
        [[DKImageManager shareInstance] groupDataManager].assetGroupTypes = assetGroupTypes;
    }
}
- (void)setAssetType:(DKImagePickerControllerAssetType)assetType{
    if (_assetType != assetType) {
        _assetType = assetType;
        [[DKImageManager shareInstance] groupDataManager].assetFetchOptions = [self createAssetFetchOptions];
    }
}

- (void)setShowsEmptyAlbums:(BOOL)showsEmptyAlbums{
    if (_showsEmptyAlbums != showsEmptyAlbums) {
        _showsEmptyAlbums = showsEmptyAlbums;
        [[DKImageManager shareInstance] groupDataManager].showsEmptyAlbums = showsEmptyAlbums;
    }
}

- (void)setAssetFilter:(BOOL (^)(PHAsset *))assetFilter{
    if (_assetFilter != assetFilter) {
        _assetFilter = assetFilter;
        [[DKImageManager shareInstance] groupDataManager].assetFilter = assetFilter;
        
    }
}

- (void)setSourceType:(DKImagePickerControllerSourceType)sourceType {
    if (_sourceType != sourceType) {
        _sourceType = sourceType;
        _hasInitialized = NO;
        
    }
}
- (DKImagePickerControllerDefaultUIDelegate *)UIDelegate{
    if (!_UIDelegate) {
        _UIDelegate  = [DKImagePickerControllerDefaultUIDelegate new];
    }
    return _UIDelegate;
    
}

- (void)setImageFetchPredicate:(NSPredicate *)imageFetchPredicate{
    if (_imageFetchPredicate != imageFetchPredicate) {
        _imageFetchPredicate = imageFetchPredicate;
        [[DKImageManager shareInstance] groupDataManager].assetFetchOptions = [self createAssetFetchOptions];
    }
}
- (void)setVideoFetchPredicate:(NSPredicate *)videoFetchPredicate{
    if (_videoFetchPredicate != videoFetchPredicate) {
        _videoFetchPredicate  = videoFetchPredicate;
        [[DKImageManager shareInstance] groupDataManager].assetFetchOptions = [self createAssetFetchOptions];
    }
}
- (void)setAutoDownloadWhenAssetIsInCloud:(BOOL)autoDownloadWhenAssetIsInCloud{
    if (_autoDownloadWhenAssetIsInCloud != autoDownloadWhenAssetIsInCloud) {
        _autoDownloadWhenAssetIsInCloud = autoDownloadWhenAssetIsInCloud;
        [DKImageManager shareInstance].autoDownloadWhenAssetIsInCloud = YES;
    }
}

- (void)setDefaultSelectedAssets:(NSArray<DKAsset *> *)defaultSelectedAssets{
        _defaultSelectedAssets = defaultSelectedAssets;
        self.selectedAssets = defaultSelectedAssets ? defaultSelectedAssets.mutableCopy : @[].mutableCopy;
        if ([self.viewControllers.firstObject isKindOfClass:[DKAssetGroupDetailVC class]]) {
            DKAssetGroupDetailVC * vc = (DKAssetGroupDetailVC *)self.viewControllers.firstObject;
            [vc.collectionView reloadData];
        }
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (PHFetchOptions *)createAssetFetchOptions{
    
    NSPredicate * (^createImagePredicate)() = ^{
       NSPredicate * imagePredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"mediaType == %ld", (long)PHAssetMediaTypeImage]];
        if (self.imageFetchPredicate) {
            imagePredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[imagePredicate, self.imageFetchPredicate]];
        }
        return imagePredicate;
    };
    
    NSPredicate * (^createVideoPredicate)() = ^{
        NSPredicate * videoPredicate = [NSPredicate predicateWithFormat:[NSString stringWithFormat:@"mediaType == %ld", (long)PHAssetMediaTypeVideo]];
        if (self.videoFetchPredicate) {
            videoPredicate = [NSCompoundPredicate andPredicateWithSubpredicates:@[videoPredicate, self.videoFetchPredicate]];
        }
        return videoPredicate;
    };
    
    
    NSPredicate * predicate;
    switch (self.assetType) {
        case DKImagePickerControllerAssetAllAssetsType:
            predicate = [NSCompoundPredicate orPredicateWithSubpredicates:@[createImagePredicate(), createVideoPredicate()]];
            break;
        case DKImagePickerControllerAssetAllPhotosType:
            predicate = createImagePredicate();
            break;
        case DKImagePickerControllerAssetAllVideosType:
            predicate = createVideoPredicate();
            break;
        default:
            break;
    }
    self.assetFetchOptions.predicate = predicate;
    return self.assetFetchOptions;
}
- (void)selectImage:(DKAsset *)asset{
    if (self.singleSelect) {
        [self deselectAllAssets];
        [self.selectedAssets addObject:asset];
        [self done];
    }else{
        [self.selectedAssets addObject:asset];
        if (self.sourceType == DKImagePickerControllerSourceCameraType) {
            [self done];
        }else{
            [self.UIDelegate imagePickerController:self didSelectAssets:@[asset]];
        }
    }
}

- (void)deselectAllAssets{
    if (self.selectedAssets.count > 0) {
        NSArray * assets = [self.selectedAssets copy];
        [self.selectedAssets removeAllObjects];
        [self.UIDelegate imagePickerController:self didDeselectAssets:assets];
        UIViewController * vc = self.viewControllers.firstObject;
        if ([vc isKindOfClass:[DKAssetGroupDetailVC class]]) {
            [((DKAssetGroupDetailVC *)vc).collectionView reloadData];
        }
    }
}

- (void)deselectImage:(DKAsset *)asset{
    [self.selectedAssets removeObject:asset];
    [self.UIDelegate imagePickerController:self didDeselectAssets:@[asset]];
}

- (void)presentCamera{
    [self presentViewController:[self createCamera] animated:YES completion:nil];
}

- (UIViewController *)createCamera{
    void(^didCancel)() = ^{
        if (self.sourceType == DKImagePickerControllerSourceCameraType) {
            if (self.presentedViewController != nil) {
                [self dismissViewControllerAnimated:YES completion:nil];
            }
            [self dismissAnimated:YES];
        }else{
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    };
    
    void (^ didFinishCapturingImage)(UIImage *) = ^(UIImage * image){
        __block NSString * newImageIdentifier;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
          PHAssetChangeRequest * assetRequest = [PHAssetChangeRequest creationRequestForAssetFromImage:image];
            newImageIdentifier = assetRequest.placeholderForCreatedAsset.localIdentifier;
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                    PHAsset * newAsset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[newImageIdentifier] options:nil] firstObject];
                    if (newAsset) {
                        if (self.presentedViewController != nil) {
                            [self dismissViewControllerAnimated:YES completion:nil];
                        }
                        
                        [self selectImage:[[DKAsset alloc] initWithOriginalAsset:newAsset]];
                    }
                    
                }else{
                    if (self.sourceType != DKImagePickerControllerSourceCameraType) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    [self selectImage:[[DKAsset alloc] initWithImage:image]];
                }
            });
        }];
    };
    
    void(^ didFinishCapturingVideo) (NSURL *) = ^(NSURL * videoURL){
        __block NSString * newVideoIdentifier;
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
           PHAssetChangeRequest * assetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:videoURL];
            newVideoIdentifier = assetRequest.placeholderForCreatedAsset.localIdentifier;
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if (success) {
                   PHAsset * newAsset = [[PHAsset fetchAssetsWithLocalIdentifiers:@[newVideoIdentifier] options:nil] firstObject];
                    
                    if (self.sourceType != DKImagePickerControllerSourceCameraType || self.viewControllers.count == 0) {
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }
                    
                    [self selectImage:[[DKAsset alloc] initWithOriginalAsset:newAsset]];
                }else{
                    [self dismissViewControllerAnimated:YES completion:nil];
                }
            });
        }];
    };
    
    UIViewController <DKImagePickerControllerCameraProtocol> * camera =  [self.UIDelegate imagePickerControllerCreateCamera:self];
    [camera setDidCancel:didCancel];
    [camera setDidFinishCapturingImage:didFinishCapturingImage];
    [camera setDidFinishCapturingVideo:didFinishCapturingVideo];
    
    return camera;
}

- (void)dismiss{
    [self dismissAnimated:YES];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[DKImageManager shareInstance] invalidate];
}

- (void)dismissAnimated:(BOOL)flag{
    [self.presentingViewController dismissViewControllerAnimated:flag completion:^{
        if (self.didCancel) {
            self.didCancel();
        }
       
    }];
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
