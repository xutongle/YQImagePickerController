//
//  YQImagePickerController.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/17.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit
import Photos

@objc protocol YQImagePickerControllerDelegate: NSObjectProtocol {

    //选取完普通图片之后会执行该代理方法
  @objc optional func imagePickerController(_ picker: YQImagePickerController!, didFinishPickingPhotos photos: [UIImage]!, sourceAssets assets: [Any]!, isSelectOriginalPhoto: Bool)
    
    //选取完一张GIF动图之后会执行该代理方法
  @objc optional func imagePickerController(_ picker: YQImagePickerController!, didFinishPickingGifImage animatedImage: UIImage!, sourceAssets asset: Any!)
    
    //选取完视频资源之后会执行该代理方法
  @objc optional func imagePickerController(_ picker: YQImagePickerController!, didFinishPickingVideo coverImage: UIImage!, sourceAssets asset: Any!)
    
    //用户点击取消按钮后会执行该代理方法
  @objc optional func imagePickerControllerDidClickCancelButton(_ picker: YQImagePickerController!)
    
}


//MARK:- YQImagePickerController 基本属性和简单的设置

class YQImagePickerController: UINavigationController {
    
    weak var pickerDelegate: YQImagePickerControllerDelegate?
    
    private var maxImageCount: NSInteger = 9
    
    private var columnNumber: NSInteger = 3
    
    convenience init(delegate: YQImagePickerControllerDelegate?){
        
        self.init(maxImageCount: 9, columnNumber: 3, delegate: delegate)
    }
    
    convenience init(maxImageCount: NSInteger, delegate: YQImagePickerControllerDelegate?){
        
        self.init(maxImageCount: maxImageCount, columnNumber: 3, delegate: delegate)
    }
 
    convenience init(columnNumber: NSInteger, delegate: YQImagePickerControllerDelegate?){
        
        self.init(maxImageCount: 9, columnNumber: columnNumber, delegate: delegate)
    }
    
    init(maxImageCount: NSInteger, columnNumber: NSInteger, delegate: YQImagePickerControllerDelegate?){
        
        self.maxImageCount = maxImageCount
        
        self.columnNumber = columnNumber
        
        self.pickerDelegate = delegate
        
        let rootViewController = YQImageController(maxImageCount: self.maxImageCount, columnNumber: self.columnNumber)
        
        super.init(rootViewController: rootViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()  //
        
        //设置导航栏基本样式
        self.setupNavgationBar()
    }
    
    //重写系统的初始化方法
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    //固定写法
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK:- 设置导航栏

extension YQImagePickerController {
    
    func setupNavgationBar() {
        
        self.view.backgroundColor = UIColor.white
        self.navigationBar.barStyle = .black;
        self.navigationBar.isTranslucent = true;
        self.navigationBar.barTintColor = UIColor(red: (34/255.0), green: (34/255.0), blue: (34/255.0), alpha: 1.0)
        self.navigationBar.tintColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false;
        
        
        //let titleView = UIButton(frame: CGRect(x: 0, y: 0, width: 200, height: 30))
        //titleView.addTarget(self, action: #selector(YQImagePickerController.titleViewDidClick), for: .touchUpInside)
        //titleView.titleLabel?.text = "导航栏"
        //titleView.backgroundColor = UIColor.red
        //self.navigationItem.titleView = titleView
    }
}

//MARK:- YQAlbumDropdownMenuDelegate

extension YQImagePickerController: YQAlbumDropdownMenuDelegate {

    func dropdownMenu(_ dropdownMenu: YQAlbumDropdownMenu, didSelectRowAt index: NSInteger) {
        
    }
    
    func dropdownMenuShowShow(_ imagePicker: YQAlbumDropdownMenu) -> Bool {
        return true
    }
    
    func dropdownMenuShowHide(_ imagePicker: YQAlbumDropdownMenu) -> Bool {
        return false
    }
    
}
