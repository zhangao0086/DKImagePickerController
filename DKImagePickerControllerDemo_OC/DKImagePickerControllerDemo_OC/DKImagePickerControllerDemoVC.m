//
//  DKImagePickerControllerDemoVC.m
//  DKImagePickerControllerDemo_OC
//
//  Created by zm on 2017/6/23.
//  Copyright © 2017年 zm. All rights reserved.
//

#import "DKImagePickerControllerDemoVC.h"
#import "ViewController.h"
#import "DKImagePickerController.h"
#import "CustomCameraUIDelegate.h"
#import "CustomUIDelegate.h"
#import "CustomLayoutUIDelegate.h"
@interface DKImagePickerControllerDemoVC ()

@end

@implementation DKImagePickerControllerDemoVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//#warning Incomplete implementation, return the number of sections
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//#warning Incomplete implementation, return the number of rows
//    return 0;
//}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    UITableViewCell * cell = (UITableViewCell *)sender;
    ViewController * vc = (ViewController *)segue.destinationViewController;
    vc.title= cell.textLabel.text;
    if ([segue.identifier isEqualToString:@"Pick All"]) {
        vc.pickerController = [DKImagePickerController new];
    }
    if ([segue.identifier isEqualToString:@"Pick Photos Only"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.assetType = DKImagePickerControllerAssetAllPhotosType;
        vc.pickerController = pc;
    }
    
    if ([segue.identifier isEqualToString:@"Pick Videos Only"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.assetType = DKImagePickerControllerAssetAllVideosType;
        vc.pickerController = pc;
    }
    
    if ([segue.identifier isEqualToString:@"Pick All(Only Photos Or Videos)"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.allowMultipleTypes = NO;
        vc.pickerController = pc;
    }
    if ([segue.identifier isEqualToString:@"Single Select"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.singleSelect = YES;
        vc.pickerController = pc;

    }
    
    if ([segue.identifier isEqualToString:@"Take A Picture"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.sourceType = DKImagePickerControllerSourceCameraType;
        vc.pickerController = pc;
    }
    
    if ([segue.identifier isEqualToString:@"Hides Camera"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.sourceType = DKImagePickerControllerSourcePhotoType;
        vc.pickerController = pc;
    }
    
    if ([segue.identifier isEqualToString:@"Allows Landscape"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.allowsLandscape = YES;
        vc.pickerController = pc;
    }
    
    if ([segue.identifier isEqualToString:@"Camera Customization"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.UIDelegate = [CustomCameraUIDelegate new];
        pc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.pickerController = pc;

    }
    if ([segue.identifier isEqualToString:@"UI Customization"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.UIDelegate = [CustomUIDelegate new];
        pc.showsCancelButton = YES;
        pc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.pickerController = pc;
    }
    
    if ([segue.identifier isEqualToString:@"Layout Customization"]) {
        DKImagePickerController * pc  = [DKImagePickerController new];
        pc.UIDelegate = [CustomLayoutUIDelegate new];
        pc.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        vc.pickerController = pc;
    }
    
    
}


@end
