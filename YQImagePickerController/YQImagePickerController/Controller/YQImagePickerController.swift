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
    @objc optional func imagePickerController(_ picker: YQImagePickerController, didFinishPickingPhotos photos: [UIImage], sourceAssets assets: [PHAsset], isSelectOriginalPhoto: Bool)
    
    //选取完一张GIF动图之后会执行该代理方法
    @objc optional func imagePickerController(_ picker: YQImagePickerController, didFinishPickingGifImage animatedImage: UIImage, sourceAssets asset: PHAsset)
    
    //选取完视频资源之后会执行该代理方法
    @objc optional func imagePickerController(_ picker: YQImagePickerController, didFinishPickingVideo coverImage: UIImage, sourceAssets asset: PHAsset)
    
    //用户点击取消按钮后会执行该代理方法
    @objc optional func imagePickerControllerCancelButtonDidClick(_ picker: YQImagePickerController)
    
}


//MARK:- YQImagePickerController

//最多可以选取的图片总数
private let maxImageCount: NSInteger = 9
//每行可以显示的图片个数
private let columnNumber: NSInteger = 3

class YQImagePickerController: UINavigationController {
    
//MARK:- TODO 增加不限制选取图片总数的公开属性
    
    private weak var pickerDelegate: YQImagePickerControllerDelegate?
    
    public convenience init(delegate: YQImagePickerControllerDelegate?){
        
        self.init(maxImageCount: maxImageCount, columnNumber: columnNumber, delegate: delegate)
    }
    
    public convenience init(maxImageCount: NSInteger, delegate: YQImagePickerControllerDelegate?){
        
        self.init(maxImageCount: maxImageCount, columnNumber: columnNumber, delegate: delegate)
    }
    
    public convenience init(columnNumber: NSInteger, delegate: YQImagePickerControllerDelegate?){
        
        self.init(maxImageCount: maxImageCount, columnNumber: columnNumber, delegate: delegate)
    }
    
    public init(maxImageCount: NSInteger, columnNumber: NSInteger, delegate: YQImagePickerControllerDelegate?){
        
        self.pickerDelegate = delegate
        let rootViewController = YQImageController(maxImageCount: maxImageCount, columnNumber: columnNumber)
        super.init(rootViewController: rootViewController)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupNavgationBar()
    }
    
    private func setupNavgationBar() {
        
        self.view.backgroundColor = UIColor.white
        self.navigationBar.barStyle = .black;
        self.navigationBar.isTranslucent = true;
        self.navigationBar.barTintColor = UIColor(red: (34/255.0), green: (34/255.0), blue: (34/255.0), alpha: 1.0)
        self.navigationBar.tintColor = UIColor.white
        self.automaticallyAdjustsScrollViewInsets = false;
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


