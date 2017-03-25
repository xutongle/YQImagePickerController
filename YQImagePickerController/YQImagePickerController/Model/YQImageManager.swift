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
    
}
