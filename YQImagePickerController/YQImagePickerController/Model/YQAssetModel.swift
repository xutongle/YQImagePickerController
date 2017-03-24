//
//  YQAssetModel.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//
//   一个图片/视频 资源模型

import UIKit

//图片/视频 资源模型类型
enum YQAssetModelType: NSInteger {
    
    case YQAssetModelTypePhoto //普通图片
    case YQAssetModelTypeLivePhoto  //LivePhoto
    case YQAssetModelTypePhotoGif  //GIF动图
    case YQAssetModelTypeVideo  //视频
    case YQAssetModelTypeAudio  //音频
}

class YQAssetModel: NSObject {
    
    //var type: YQAssetModelType
    //是否选中
    var isSelected: Bool = false
    //持续时长
    var durationTime: String = ""
    
}
