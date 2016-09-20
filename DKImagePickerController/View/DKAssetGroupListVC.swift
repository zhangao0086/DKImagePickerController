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
                if newValue != UIColor.clear {
                    super.backgroundColor = newValue
                }
            }
        }
    }
    
	fileprivate let thumbnailImageView: UIImageView = {
		let thumbnailImageView = UIImageView()
		thumbnailImageView.contentMode = .scaleAspectFill
		thumbnailImageView.clipsToBounds = true
		
		return thumbnailImageView
	}()
	
    var groupNameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    }()
	
    var totalCountLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.gray
        return label
    }()
    
    var customSelectedBackgroundView: UIView = {
        let selectedBackgroundView = UIView()
        
        let selectedFlag = UIImageView(image: DKImageResource.blueTickImage())
        selectedFlag.frame = CGRect(x: selectedBackgroundView.bounds.width - selectedFlag.bounds.width - 20,
            y: (selectedBackgroundView.bounds.width - selectedFlag.bounds.width) / 2,
            width: selectedFlag.bounds.width, height: selectedFlag.bounds.height)
        selectedFlag.autoresizingMask = [.flexibleLeftMargin, .flexibleTopMargin, .flexibleBottomMargin]
        selectedBackgroundView.addSubview(selectedFlag)
        
        return selectedBackgroundView
    }()
    
    lazy var customSeparator: DKAssetGroupSeparator = {
        let separator = DKAssetGroupSeparator(frame: CGRect(x: 10, y: self.bounds.height - 1, width: self.bounds.width, height: 0.5))
        
        separator.backgroundColor = UIColor.lightGray
        separator.autoresizingMask = [.flexibleWidth, .flexibleTopMargin]
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
    
	convenience init(selectedGroupDidChangeBlock: @escaping (_ groupId: String?) -> (), defaultAssetGroup: PHAssetCollectionSubtype?) {
		self.init(style: .plain)
		
		self.defaultAssetGroup = defaultAssetGroup
		self.selectedGroupDidChangeBlock = selectedGroupDidChangeBlock
	}
	
	fileprivate var groups: [String]?
	
	fileprivate var selectedGroup: String?
	
	fileprivate var defaultAssetGroup: PHAssetCollectionSubtype?
	
    fileprivate var selectedGroupDidChangeBlock:((_ group: String?)->())?
	
	fileprivate lazy var groupThumbnailRequestOptions: PHImageRequestOptions = {
		let options = PHImageRequestOptions()
		options.deliveryMode = .opportunistic
		options.resizeMode = .exact
		
		return options
	}()
    
    override var preferredContentSize: CGSize {
        get {
            if let groups = self.groups {
                return CGSize(width: UIViewNoIntrinsicMetric, height: CGFloat(groups.count) * self.tableView.rowHeight)
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
        
        self.tableView.register(DKAssetGroupCell.self, forCellReuseIdentifier: DKImageGroupCellIdentifier)
        self.tableView.rowHeight = 70
        self.tableView.separatorStyle = .none
        
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
					strongSelf.tableView.selectRow(at: IndexPath(row: groups!.index(of: selectedGroup)!, section: 0),
						animated: false,
						scrollPosition: .none)
				}
				
				strongSelf.selectedGroupDidChangeBlock?(strongSelf.selectedGroup)
			}
		}
	}
	
	fileprivate func defaultAssetGroupOfAppropriate() -> String? {
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
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: DKImageGroupCellIdentifier, for: indexPath) as! DKAssetGroupCell
		
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
        cell.totalCountLabel.text = String(assetGroup.totalCount)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DKPopoverViewController.dismissPopoverViewController()
		
		self.selectedGroup = self.groups![indexPath.row]
		selectedGroupDidChangeBlock?(self.selectedGroup)
    }
	
	// MARK: - DKGroupDataManagerObserver methods
	
	func groupDidUpdate(_ groupId: String) {
		let indexPath = IndexPath(row: self.groups!.index(of: groupId)!, section: 0)
		self.tableView.reloadRows(at: [indexPath], with: .none)
	}
	
	func groupDidRemove(_ groupId: String) {
		let indexPath = IndexPath(row: self.groups!.index(of: groupId)!, section: 0)
		self.groups?.remove(at: indexPath.row)
		self.tableView.deleteRows(at: [indexPath], with: .none)
		
		if self.selectedGroup == groupId {
			self.selectedGroup = self.groups?.first
			selectedGroupDidChangeBlock?(self.selectedGroup)
			self.tableView.selectRow(at: IndexPath(row: 0, section: 0), animated: false, scrollPosition: .none)
		}
	}
    
}
