//
//  DKAssetGroupVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/8.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import UIKit

let DKImageGroupCellIdentifier = "DKImageGroupCellIdentifier"

class DKAssetGroupCell: UITableViewCell {
    
    class DKAssetGroupSeparator: UIView {

        override var backgroundColor: UIColor? {
            get {
                return super.backgroundColor
            }
            set {
                if newValue != UIColor.clearColor() {
                    super.backgroundColor = newValue
                }
            }
        }
    }
    
    var thumbnailImageView = UIImageView()
    var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(13)
        return label
    }()
    var totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(11)
        label.textColor = UIColor.grayColor()
        return label
    }()
    
    var customSelectedBackgroundView: UIView = {
        let selectedBackgroundView = UIView()
        
        let selectedFlag = UIImageView(image: DKImageResource.blueTickImage())
        selectedFlag.frame = CGRect(x: selectedBackgroundView.bounds.width - selectedFlag.bounds.width - 20,
            y: (selectedBackgroundView.bounds.width - selectedFlag.bounds.width) / 2,
            width: selectedFlag.bounds.width, height: selectedFlag.bounds.height)
        selectedFlag.autoresizingMask = .FlexibleLeftMargin | .FlexibleTopMargin | .FlexibleBottomMargin
        selectedBackgroundView.addSubview(selectedFlag)
        
        return selectedBackgroundView
    }()
    
    lazy var customSeparator: DKAssetGroupSeparator = {
        let separator = DKAssetGroupSeparator(frame: CGRectMake(10, self.bounds.height - 1, self.bounds.width, 0.5))
        
        separator.backgroundColor = UIColor.lightGrayColor()
        separator.autoresizingMask = .FlexibleWidth | .FlexibleTopMargin
        return separator
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectedBackgroundView = self.customSelectedBackgroundView
        
        self.contentView.addSubview(thumbnailImageView)
        self.contentView.addSubview(groupNameLabel)
        self.contentView.addSubview(totalCountLabel)

        self.addSubview(self.customSeparator)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let imageViewY = CGFloat(10)
        let imageViewHeight = self.contentView.bounds.height - 2 * imageViewY
        self.thumbnailImageView.frame = CGRect(x: imageViewY, y: imageViewY,
            width: imageViewHeight, height: imageViewHeight)
        
        self.groupNameLabel.frame = CGRect(x: self.thumbnailImageView.frame.maxX + 10, y: self.thumbnailImageView.frame.minY + 5,
            width: 200, height: 20)
        
        self.totalCountLabel.frame = CGRect(x: self.groupNameLabel.frame.minX, y: self.thumbnailImageView.frame.maxY - 20, width: 200, height: 20)
    }
    
}

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
        
        self.tableView.registerClass(DKAssetGroupCell.self, forCellReuseIdentifier: DKImageGroupCellIdentifier)
        self.tableView.rowHeight = 70
        self.tableView.separatorStyle = .None
        
        self.clearsSelectionOnViewWillAppear = false
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DKImageGroupCellIdentifier, forIndexPath: indexPath) as! DKAssetGroupCell
        
        let assetGroup = groups![indexPath.row] as DKAssetGroup
        cell.groupNameLabel.text = assetGroup.groupName
        cell.thumbnailImageView.image = assetGroup.thumbnail
        cell.totalCountLabel.text = "\(assetGroup.totalCount)"
        
        if indexPath.row == 0 && tableView.indexPathForSelectedRow() == nil {
            tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DKPopoverViewController.dismissPopoverViewController()
        
        let assetGroup = groups![indexPath.row] as DKAssetGroup
        if let selectedGroupBlock = self.selectedGroupBlock {
            selectedGroupBlock(assetGroup: assetGroup)
        }
    }
    
}