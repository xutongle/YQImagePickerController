//
//  YQAlbumModel.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/24.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//  
//   一个相册模型

import UIKit
import Photos

class YQAlbumModel: NSObject {

    //相册的名称
    var name: String = ""
    //相册的所有图片数量
    var count: NSInteger = 0
    //相册中已经选中的图片数量
    var selectedCount: NSInteger = 0
    //结果
    var result: PHFetchResult<PHAsset>?
    //相册中所有的资源模型
    var assetModels: [YQAssetModel]?
    //相册中已经被选中的资源模型
    var selectedAssetModels: [YQAssetModel]?
}
