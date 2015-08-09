//
//  DKAssetGroupVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/8.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

class DKAssetGroupVC: UITableViewController {
    
    var groups: [DKAssetGroup]?
    
    var selectedGroupBlock:((assetGroup: DKAssetGroup)->())?
    
    override var preferredContentSize: CGSize {
        get {
            if let groups = self.groups {
                return CGSizeMake(UIViewNoIntrinsicMetric, CGFloat(groups.count) * self.tableView.rowHeight)
            } else {
                return super.preferredContentSize
            }
        }
        set {
            super.preferredContentSize = newValue
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: GroupCellIdentifier)
        self.tableView.rowHeight = 50
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(GroupCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        
        let assetGroup = groups![indexPath.row] as DKAssetGroup
        cell.textLabel!.text = assetGroup.groupName
        cell.imageView!.image = assetGroup.thumbnail
        
        let selectedBackgroundView = UIView()
        selectedBackgroundView.backgroundColor = UIColor.redColor()
        cell.selectedBackgroundView = selectedBackgroundView
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        let assetGroup = groups![indexPath.row] as DKAssetGroup
        if let selectedGroupBlock = self.selectedGroupBlock {
            selectedGroupBlock(assetGroup: assetGroup)
        }
        
        FBPopoverViewController.dismissPopoverViewController()
    }
    
}