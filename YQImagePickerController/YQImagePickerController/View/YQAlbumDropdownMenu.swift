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
    
   @objc optional func dropdownMenuWillShow(_ imagePicker: YQAlbumDropdownMenu) -> Bool
   @objc optional func dropdownMenuWillHide(_ imagePicker: YQAlbumDropdownMenu) -> Bool
   @objc optional func dropdownMenu(_ dropdownMenu: YQAlbumDropdownMenu, didSelectRowAt index: NSInteger)
}


//相册集cell的高度
private let YQAlbumCellHeight: CGFloat = 60.0

open class YQAlbumDropdownMenu: UIView {
    
    //用户手机中所有的相册集数组
    var allAlbums: [YQAlbumModel]?
    
    //代理属性
    weak var delegate: YQAlbumDropdownMenuDelegate?
    
    //显示相册集的tabeView - 懒加载
    lazy var tableView: UITableView = UITableView(frame: .zero, style: .plain)
    
    
    //快速创建DropdownMenu
    init(allAlbums: [YQAlbumModel], delegate: YQAlbumDropdownMenuDelegate?) {
        
        super.init(frame: .zero)
        
        self.allAlbums = allAlbums
        
        self.delegate = delegate
    
        //设置数据源和代理
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //注册cell
        tableView.register(YQAlbumCell.self, forCellReuseIdentifier: "cellid")
        
        self.addSubview(tableView)
    }
    
    
    //设置子空间的尺寸和位置
    open override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.tableView.frame = self.bounds
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK:- 显示和隐藏 YQAlbumDropdownMenu

extension YQAlbumDropdownMenu {

    func showInView(view: UIView) {
    
        if (self.delegate == nil) {
            return
        }
        
        if self.delegate?.dropdownMenuWillShow!(self) == false {
            return
        }
        
        print(view.frame)
        
        let point = CGPoint(x: 0, y: 64)
        
        view.addSubview(self)
        //self.frame = view.bounds
        
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(origin: point, size: self.tableView.frame.size)
        }
    }
    
    func hide() {
        
        if (self.delegate == nil) {
            return
        }
        
        if self.delegate?.dropdownMenuWillHide!(self) == false {
            return
        }
        
        UIView.animate(withDuration: 0.3, animations: {
            
            self.transform = CGAffineTransform(translationX: 0, y: -self.tableView.frame.size.height)
            self.alpha = 0.0
            
        }) { (true) in
            self.removeFromSuperview()
        }
    }
}

//MARK:- UITableViewDataSource && UITableViewDelegate
extension YQAlbumDropdownMenu: UITableViewDataSource, UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        //return (allAlbums?.count)!
        return 4
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellid", for: indexPath)
        
        cell.backgroundColor = UIColor.green
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if ((delegate?.dropdownMenu!(self, didSelectRowAt: indexPath.row)) != nil) {
            delegate?.dropdownMenu!(self, didSelectRowAt: indexPath.row)
        }
    }
}

