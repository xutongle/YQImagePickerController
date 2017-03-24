//
//  YQAlbumDropdownMenu.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit

//MARK:- YQAlbumDropdownMenuDelegate
@objc public protocol YQAlbumDropdownMenuDelegate {
    
    func dropdownMenuShowShow(_ imagePicker: YQAlbumDropdownMenu) -> Bool
    func dropdownMenuShowHide(_ imagePicker: YQAlbumDropdownMenu) -> Bool
    func dropdownMenu(_ dropdownMenu: YQAlbumDropdownMenu, didSelectRowAt index: NSInteger)
}

class YQAlbumCell: UITableViewCell {
    
}


open class YQAlbumDropdownMenu: UIView {
    
    //用户手机中所有的相册集
    var items: [YQAssetModel]?
    
    //显示相册集的tabeView - 懒加载
    lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    //代理属性
    weak var delegate: YQAlbumDropdownMenuDelegate?
    
    //快速创建DropdownMenu
    init(items: [YQAssetModel]) {
        
        super.init(frame: .zero)
        
        self.items = items
    
        self.setupView()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupView() {
        
        //设置数据源和代理
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //注册cell
        tableView.register(YQAlbumCell.self, forCellReuseIdentifier: "cellid")
    }
}


//MARK:- UITableViewDataSource && UITableViewDelegate
extension YQAlbumDropdownMenu: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return (items?.count)!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        
        cell.backgroundColor = UIColor.red
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((delegate?.dropdownMenu(self, didSelectRowAt: indexPath.row)) != nil) {
            delegate?.dropdownMenu(self, didSelectRowAt: indexPath.row)
        }
    }
}

