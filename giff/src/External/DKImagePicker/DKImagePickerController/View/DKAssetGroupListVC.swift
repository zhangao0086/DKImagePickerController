//
//  DKAssetGroupListVC.swift
//  DKImagePickerController
//
//  Created by ZhangAo on 15/8/8.
//  Copyright (c) 2015年 ZhangAo. All rights reserved.
//

import Photos

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
    
	private let thumbnailImageView: UIImageView = {
		let thumbnailImageView = UIImageView()
		thumbnailImageView.contentMode = .ScaleAspectFill
		thumbnailImageView.clipsToBounds = true
		
		return thumbnailImageView
	}()
	
    var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFontOfSize(13)
        return label
    }()
	
    var totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(10)
        label.textColor = UIColor.grayColor()
        return label
    }()
    
    var customSelectedBackgroundView: UIView = {
        let selectedBackgroundView = UIView()
        
        let selectedFlag = UIImageView(image: DKImageResource.blueTickImage())
        selectedFlag.frame = CGRect(x: selectedBackgroundView.bounds.width - selectedFlag.bounds.width - 20,
            y: (selectedBackgroundView.bounds.width - selectedFlag.bounds.width) / 2,
            width: selectedFlag.bounds.width, height: selectedFlag.bounds.height)
        selectedFlag.autoresizingMask = [.FlexibleLeftMargin, .FlexibleTopMargin, .FlexibleBottomMargin]
        selectedBackgroundView.addSubview(selectedFlag)
        
        return selectedBackgroundView
    }()
    
    lazy var customSeparator: DKAssetGroupSeparator = {
        let separator = DKAssetGroupSeparator(frame: CGRectMake(10, self.bounds.height - 1, self.bounds.width, 0.5))
        
        separator.backgroundColor = UIColor.lightGrayColor()
        separator.autoresizingMask = [.FlexibleWidth, .FlexibleTopMargin]
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

    required init?(coder aDecoder: NSCoder) {
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

class DKAssetGroupListVC: UITableViewController, DKGroupDataManagerObserver {
    
	convenience init(selectedGroupDidChangeBlock: (groupId: String?) -> (), defaultAssetGroup: PHAssetCollectionSubtype?) {
		self.init(style: .Plain)
		
		self.defaultAssetGroup = defaultAssetGroup
		self.selectedGroupDidChangeBlock = selectedGroupDidChangeBlock
	}
	
	private var groups: [String]?
	
	private var selectedGroup: String?
	
	private var defaultAssetGroup: PHAssetCollectionSubtype?
	
    private var selectedGroupDidChangeBlock:((group: String?)->())?
	
	private lazy var groupThumbnailRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .Opportunistic
		options.resizeMode = .Exact
		
		return options
	}()
    
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
		
		getImageManager().groupDataManager.addObserver(self)
	}
	
	internal func loadGroups() {
		getImageManager().groupDataManager.fetchGroups { [weak self] groups, error in
			guard let strongSelf = self else { return }
			
			if error == nil {
				strongSelf.groups = groups!
				strongSelf.selectedGroup = strongSelf.defaultAssetGroupOfAppropriate()
				if let selectedGroup = strongSelf.selectedGroup {
					strongSelf.tableView.selectRowAtIndexPath(NSIndexPath(forRow: groups!.indexOf(selectedGroup)!, inSection: 0),
						animated: false,
						scrollPosition: .None)
				}
				
				strongSelf.selectedGroupDidChangeBlock?(group: strongSelf.selectedGroup)
			}
		}
	}
	
	private func defaultAssetGroupOfAppropriate() -> String? {
		if let groups = self.groups {
			if let defaultAssetGroup = self.defaultAssetGroup {
				for groupId in groups {
					let group = getImageManager().groupDataManager.fetchGroupWithGroupId(groupId)
					if defaultAssetGroup == group.originalCollection.assetCollectionSubtype {
						return groupId
					}
				}
			}
			return self.groups!.first
		}
		return nil
	}
	
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?.count ?? 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(DKImageGroupCellIdentifier, forIndexPath: indexPath) as! DKAssetGroupCell
		
        let assetGroup = getImageManager().groupDataManager.fetchGroupWithGroupId(groups![indexPath.row])
        cell.groupNameLabel.text = assetGroup.groupName
		
		let tag = indexPath.row + 1
		cell.tag = tag
		
		if assetGroup.totalCount == 0 {
			cell.thumbnailImageView.image = DKImageResource.emptyAlbumIcon()
		} else {
			getImageManager().groupDataManager.fetchGroupThumbnailForGroup(assetGroup.groupId,
				size: CGSize(width: tableView.rowHeight, height: tableView.rowHeight).toPixel(),
				options: self.groupThumbnailRequestOptions) { image, info in
				if cell.tag == tag {
					cell.thumbnailImageView.image = image
				}
			}
		}
        cell.totalCountLabel.text = "\(assetGroup.totalCount)"
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        DKPopoverViewController.dismissPopoverViewController()
		
		self.selectedGroup = self.groups![indexPath.row]
		selectedGroupDidChangeBlock?(group: self.selectedGroup)
    }
	
	// MARK: - DKGroupDataManagerObserver methods
	
	func groupDidUpdate(groupId: String) {
		let indexPath = NSIndexPath(forRow: self.groups!.indexOf(groupId)!, inSection: 0)
		self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
	}
	
	func groupDidRemove(groupId: String) {
		let indexPath = NSIndexPath(forRow: self.groups!.indexOf(groupId)!, inSection: 0)
		self.groups?.removeAtIndex(indexPath.row)
		self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .None)
		
		if self.selectedGroup == groupId {
			self.selectedGroup = self.groups?.first
			selectedGroupDidChangeBlock?(group: self.selectedGroup)
			self.tableView.selectRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0), animated: false, scrollPosition: .None)
		}
	}
    
}