//
//  YQAlbumDropdownMenu.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit

private let YQAlbumCellId: String = "YQAlbumCellId"
//相册集cell的高度
private let YQAlbumCellHeight: CGFloat = 60.0


class YQDropdownMenu: UIView {
    
    //用户手机中所有的相册集数组
    private var allAlbums: [YQAlbumModel]?
    
    //选中下标的回调
    open var didSelectItemAtIndexHandler: ((_ indexPath: Int) -> ())?
    
    //是否正在显示
    private var isShown: Bool!
    
    fileprivate var menuTitle: UILabel!
    
    fileprivate var menuArrow: UIImageView!
    
    //显示相册集的tabeView - 懒加载
    fileprivate var tableView: UITableView!
    
    fileprivate var menuWrapper: UIView!
    
    fileprivate weak var navigationController: UINavigationController?
    
    //快速创建DropdownMenu
    public init(navigationController: UINavigationController, title: String, allAlbums: [YQAlbumModel], size: CGSize) {
        
        //计算标题长度
        //let titleSize = (title as NSString).size(attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)])
        
        //暂时设置的尺寸
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        super.init(frame:frame)
        
        //设置基本属性
        self.isShown = false
        self.backgroundColor = UIColor.green
        self.navigationController = navigationController
        
        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(YQDropdownMenu.menuDidTap))
        self.addGestureRecognizer(titleTapGesture)
        
        //设置遮盖视图
        self.menuWrapper = UIView(frame: CGRect(x: 0, y: CGFloat(64), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64))
        self.menuWrapper.backgroundColor = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.2)

        let menuWrapperTapGesture = UITapGestureRecognizer(target: self, action: #selector(YQDropdownMenu.hideMenu))
        self.menuWrapper.addGestureRecognizer(menuWrapperTapGesture)
        
        //设置相册tableView
        self.tableView = UITableView(frame: CGRect(x: 0, y: -self.menuWrapper.frame.height, width: self.menuWrapper.frame.width, height: self.menuWrapper.frame.height))
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = YQAlbumCellHeight
        self.tableView.register(YQAlbumCell.self, forCellReuseIdentifier: YQAlbumCellId)
        self.tableView.addGestureRecognizer(menuWrapperTapGesture)
        
        self.menuWrapper.addSubview(self.tableView)
    }
    
    func menuDidTap() {
        self.isShown == true ? hideMenu() : showMenu()
    }
    
    
    func hideMenu() {
        
        self.isShown = false

        UIView.animate(withDuration: 0.5, animations: { 
            self.tableView.frame.origin.y = -self.tableView.frame.height
            
        }) { (true) in
            self.menuWrapper.removeFromSuperview()
        }
    }
    
    func showMenu() {
        
        self.isShown = true
        
        self.navigationController?.view.addSubview(self.menuWrapper)
        UIView.animate(withDuration: 0.5) { 
            self.tableView.frame.origin.y = 0
        }
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}



extension YQDropdownMenu: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YQAlbumCellId)
        cell?.textLabel?.text = "222"
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if (self.didSelectItemAtIndexHandler != nil) {
            self.didSelectItemAtIndexHandler!(indexPath.row)
            //设置选中的标题文字
            //self.menuTitle.text =
        }
        
        self.hideMenu()
    }
}

