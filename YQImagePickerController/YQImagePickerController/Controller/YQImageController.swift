//
//  YQImageController.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit

//cell的重用标识
private let reuseIdentifier = "Cell"
//cell四周的边距宽度
private let cellMargin: CGFloat = 4.0
//底部工具条的高度
private let toolBarHeight: CGFloat = 54.0

class YQImageController: UICollectionViewController {
    
    private var maxImageCount: NSInteger = 9
    
    private var columnNumber: NSInteger = 3
    
    var dropdownMenu: YQDropdownMenu?
    
    //初始化方法
    init(maxImageCount: NSInteger, columnNumber: NSInteger){
        
        if maxImageCount < 0 {
            
            self.maxImageCount = 0
            print("maxImageCount 最小为0")
        }
        
        if columnNumber < 1 {
            
            self.columnNumber = 1
            print("columnNumber 最小为1")
            
        } else if (columnNumber > 5) {
            
            self.columnNumber = 5
            print("columnNumber 最多为5")
        }
        
        //设置UICollectionViewLayout属性
        let layout = UICollectionViewFlowLayout()
        
        let itemWH = (UIScreen.main.bounds.width - CGFloat(columnNumber + 1) * cellMargin) / CGFloat(columnNumber)
        
        layout.itemSize = CGSize(width: itemWH, height: itemWH)
        
        layout.minimumLineSpacing = cellMargin
        
        layout.minimumInteritemSpacing = cellMargin
        
        layout.scrollDirection = UICollectionViewScrollDirection.vertical
        
        super.init(collectionViewLayout: layout)
    }
    
    
    //MARK:- 基本设置
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //设置导航栏
        self.configNavgationBar()
        //设置底部工具条
        self.configToolBar()
        
        self.collectionView?.backgroundColor = UIColor.white
        self.collectionView?.contentInset = UIEdgeInsetsMake(cellMargin, cellMargin, toolBarHeight, cellMargin)
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//MARK:- 设置导航栏和底部工具条相关属性

extension YQImageController {
    
    func configNavgationBar() {
        
        //设置右边的预览按钮
        let rightBtn = UIBarButtonItem(title: "预览", style: .plain, target: self, action: #selector(YQImageController.previewBtnDidClick))
        self.navigationItem.rightBarButtonItem = rightBtn
        //设置左边的取消按钮
        let letfBtn = UIBarButtonItem(title: "取消", style: .plain, target: self, action: #selector(YQImageController.cancelBtnDidClick))
        self.navigationItem.leftBarButtonItem = letfBtn
        
        YQImageManager.manager.getAllAlbums(isAllowPickVideo: true, isAlowPickImage: true) { (albumModels) in
            
            //设置导航栏下拉菜单按钮
            let size = CGSize(width: self.view.frame.width - (self.navigationItem.rightBarButtonItem?.width)! * 2.0 - 20, height: 30)
            let dropdownMenu = YQDropdownMenu(navigationController: self.navigationController!, title: "8888", allAlbums: albumModels, size: size)
            dropdownMenu.didSelectItemAtIndexHandler = {(indexPath: Int) -> () in
                
                print("Did select item at index: \(indexPath)")
            }
            
            self.navigationItem.titleView = dropdownMenu
        }
    }
    
    
    func configToolBar() {
        
        let bottomToolBar = UIView(frame: CGRect(x: 0, y: UIScreen.main.bounds.size.height - toolBarHeight, width: UIScreen.main.bounds.size.width, height: toolBarHeight))
        
        bottomToolBar.backgroundColor = UIColor(displayP3Red: 253.0/255.0, green: 253.0/255.0, blue: 253.0/255.0, alpha: 1.0)
        
        //添加分割线
        let divideLine = UIView(frame: CGRect(x: 0, y: cellMargin, width: UIScreen.main.bounds.size.width, height: 1))
        
        //divideLine.backgroundColor = UIColor(displayP3Red: 222.0/255.0, green: 222.0/255.0, blue: 222.0/255.0, alpha: 1.0)
        divideLine.backgroundColor = UIColor.red
        
        bottomToolBar.addSubview(divideLine)
        
        //添加到视图上
        self.view.addSubview(bottomToolBar)
    }
    
    
    func previewBtnDidClick() {
        
        let previewVC = YQImagePreviewController()
        
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
    
    func cancelBtnDidClick() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
}


// MARK: UICollectionViewDataSource && UICollectionViewDelegate
extension YQImageController {
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return 20
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        cell.backgroundColor = UIColor.purple
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let previewVC = YQImagePreviewController()
        
        self.navigationController?.pushViewController(previewVC, animated: true)
    }
}
