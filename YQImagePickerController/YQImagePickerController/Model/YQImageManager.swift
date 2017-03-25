//
//  YQImageManager.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/25.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit
import Photos

private let YQScreenWidth: CGFloat = UIScreen.main.bounds.size.width
private var YQScreenScale: CGFloat = 2.0

class YQImageManager: NSObject {

    var cachingImageManager: PHCachingImageManager?
    
    //修复方向
    var isNeedFixOrientation: Bool!
    
    //默认600像素宽度
    var imagePreviewMaxWidth: CGFloat = 600
    
    //每行显示的图片数量
    var columnNumber: NSInteger = 3
    
    //照片是否需要按照修改时间排序，默认是true
    var isSortAscendingBymodifiedDate: Bool!
    
    //小于这个宽度尺寸的图片将不能被选中
    var minImageWidthSelectable: CGFloat = 0
    
    //小于这个高度尺寸的图片将不能被选中
    var minImageHeightSelectable: CGFloat = 0
    
    //当图片不可选时隐藏该图片，默认为true
    var isHidenWhenCanNotSelect: Bool!
    
    //单例
    static let manager: YQImageManager = {
        
        let manager = YQImageManager()
        manager.cachingImageManager = PHCachingImageManager()
        
        // 测试发现，如果scale在plus真机上取到3.0，内存会增大特别多。故这里写死成2.0
        if (YQScreenWidth > 700) {
            YQScreenScale = 1.5;
        }
        return manager
    }()
    
    //用户是否授权
    func applicationAuthorized() -> Bool {
        
        //授权状态码
        let status: PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if status == PHAuthorizationStatus.notDetermined {

            let queue = DispatchQueue.global()
            queue.async(execute: {
                PHPhotoLibrary.requestAuthorization({ (status) in
                    let queue = DispatchQueue.main
                    queue.async {
                    }
                })
            })
        }
        return status == PHAuthorizationStatus.denied
    }
}
