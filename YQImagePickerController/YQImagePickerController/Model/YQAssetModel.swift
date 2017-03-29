//
//  YQAssetModel.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//
//   一个图片/视频 资源模型

import UIKit
import Photos

//图片/视频 资源模型类型
enum YQAssetModelType: NSInteger {
    
    case photo //普通图片
    case livePhoto  //LivePhoto
    case gif  //GIF动图
    case video  //视频
    case audio  //音频
}

class YQAssetModel: NSObject {
    
    //资源
    var asset: PHAsset = PHAsset()
    //类型
    var type: YQAssetModelType = YQAssetModelType.photo
    //是否选中
    var isSelected: Bool = false
    //持续时长
    var durationTime: String?
    
    init(asset: PHAsset, type: YQAssetModelType) {
        
        self.asset = asset
        self.type = type
        self.isSelected = false
    }
    
    init(asset: PHAsset, type: YQAssetModelType, durationTime: String) {
        
        self.asset = asset
        self.type = type
        self.isSelected = false
        self.durationTime = durationTime
    }
}
