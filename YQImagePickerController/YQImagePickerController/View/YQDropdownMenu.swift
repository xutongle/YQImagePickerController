//
//  YQAlbumDropdownMenu.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit

@objc protocol YQDropdownMenuDelegate: NSObjectProtocol {
    
    //下拉菜单即将展开
    @objc optional func dropdownMenuWillOpen(_ menu: YQDropdownMenu)
    
    //下拉菜单即将收回
    @objc optional func dropdownMenuWillFold(_ menu: YQDropdownMenu)
    
    //选取完视频资源之后会执行该代理方法
    @objc optional func dropdownMenu(_ menu: YQDropdownMenu, didSelectItemAtIndex: NSInteger, selectedItem: YQAlbumModel?)
}


//相册集cell的重用标识
private let YQAlbumCellId: String = "YQAlbumCellId"
//相册集cell的高度
private let YQAlbumCellHeight: CGFloat = 60.0

class YQDropdownMenu: UIView {
    
    //代理对象
    weak var delegate: YQDropdownMenuDelegate?
    
    //显示相册集的tabeView - 懒加载
    fileprivate var tableView: UITableView!
    
    //用户手机中所有的相册集数组
    open var allAlbums: [YQAlbumModel] {
        
        didSet {
            
            self.tableView.reloadData()
        }
    }
    
    //是否正在显示
    open var isShown: Bool!
    
    fileprivate var menuTitle: UILabel!
    
    fileprivate var menuArrow: UIImageView!
    
    fileprivate var menuWrapper: UIView!
    
    fileprivate weak var navigationController: UINavigationController?
    
    //快速创建DropdownMenu
    public init(navigationController: UINavigationController, title: String, size: CGSize) {
        
        //计算标题长度
        //let titleSize = (title as NSString).size(attributes: [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16)])
        
        //暂时设置的尺寸
        let frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        
        self.allAlbums = [YQAlbumModel]()
        
        super.init(frame:frame)
        
        //设置基本属性
        self.isShown = false
        self.backgroundColor = UIColor.green
        self.navigationController = navigationController
        
        
        let titleTapGesture = UITapGestureRecognizer(target: self, action: #selector(YQDropdownMenu.menuDidTap))
        self.addGestureRecognizer(titleTapGesture)
        
        //设置遮盖视图
        self.menuWrapper = UIView(frame: CGRect(x: 0, y: CGFloat(64), width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height - 64))

        //let menuWrapperTapGesture = UITapGestureRecognizer(target: self, action: #selector(YQDropdownMenu.hideMenu))
        //self.menuWrapper.addGestureRecognizer(menuWrapperTapGesture)
        
        //设置相册tableView
        self.tableView = UITableView(frame: CGRect(x: 0, y: -self.menuWrapper.frame.height, width: self.menuWrapper.frame.width, height: self.menuWrapper.frame.height))
        self.tableView.backgroundColor = UIColor.clear
        self.tableView.tableFooterView = UIView()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.rowHeight = YQAlbumCellHeight
        self.tableView.register(YQAlbumCell.self, forCellReuseIdentifier: YQAlbumCellId)
        //self.tableView.addGestureRecognizer(menuWrapperTapGesture)
        
        self.menuWrapper.addSubview(self.tableView)
        
        self.menuTitle = UILabel(frame: frame)
        self.menuTitle.sizeToFit()
        self.menuTitle.text = title
        self.addSubview(self.menuTitle)
    }
    
    //标题按钮的点击事件
    func menuDidTap() {
        print(isShown)
        isShown == true ? hideMenu() : showMenu()
    }
    
    //显示下拉菜单
    func showMenu() {
        
        isShown = true
        
        if (delegate?.responds(to: #selector(YQDropdownMenuDelegate.dropdownMenuWillOpen(_:))))! {
            delegate?.dropdownMenuWillOpen!(self)
        }
        
        menuWrapper.backgroundColor = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.2)
        navigationController?.view.insertSubview(menuWrapper, belowSubview: (navigationController?.navigationBar)!)
        //执行动画
        UIView.animate(
            withDuration: 0.7,  //持续时间
            delay: 0,
            usingSpringWithDamping: 0.75, //弹簧效果程度
            initialSpringVelocity: 1.0, //初始化初读
            options: [],
            animations: {
                self.tableView.frame.origin.y = 0
        }) { (true) in
        }
    }
    
    //隐藏下拉菜单
    func hideMenu() {
        
        isShown = false
        
        if (delegate?.responds(to: #selector(YQDropdownMenuDelegate.dropdownMenuWillFold(_:))))! {
            delegate?.dropdownMenuWillFold!(self)
        }
        
        menuWrapper.backgroundColor = UIColor(displayP3Red: 0.0/255.0, green: 0.0/255.0, blue: 0.0/255.0, alpha: 0.0)
        //执行动画
        UIView.animate(withDuration: 1.0,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
            self.tableView.frame.origin.y = -self.tableView.frame.height
        }) { (true) in
            self.menuWrapper.removeFromSuperview()
        }
    }
    
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension YQDropdownMenu: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (allAlbums.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: YQAlbumCellId)
        cell?.textLabel?.text = allAlbums[indexPath.row].name
        //cell?.detailTextLabel?.text = allAlbums?[indexPath.row].count
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        hideMenu()
        
        //实现代理方法
        if (delegate?.responds(to: #selector(YQDropdownMenuDelegate.dropdownMenu(_:didSelectItemAtIndex:selectedItem:))))! {
            delegate?.dropdownMenu!(self, didSelectItemAtIndex: indexPath.row, selectedItem: allAlbums[indexPath.row])
        }
    }
}

