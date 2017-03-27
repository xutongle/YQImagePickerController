//
//  YQImageManager.swift
//  YQImagePickerController
//
//  Created by CoderYQ on 2017/3/25.
//  Copyright © 2017年 CoderYQ. All rights reserved.
//

import UIKit
import Photos

private var YQAssetGridThumbnailSize: CGSize = CGSize.zero
private let YQScreenWidth: CGFloat = UIScreen.main.bounds.size.width
private var YQScreenScale: CGFloat = 2.0

class YQImageManager: NSObject {
    
    var cachingImageManager: PHCachingImageManager?
    
    //修复方向
    var isNeedFixOrientation: Bool!
    
    //默认600像素宽度
    var imagePreviewMaxWidth: CGFloat = 600
    
    //每行显示的图片数量
    var columnNumber: NSInteger! {
        
        get {
            return self.columnNumber
        }
        set(value) {
            self.columnNumber = value
            
            let margin: CGFloat  = 4
            let itemWH: CGFloat  = (YQScreenWidth - CGFloat(2) * margin - CGFloat(4)) / CGFloat(columnNumber) - margin;
            YQAssetGridThumbnailSize = CGSize(width: itemWH * YQScreenScale, height: itemWH * YQScreenScale)
        }
    }
    
    //照片是否需要按照修改时间排序，默认是true
    var isSortAscendingByModifiationDate: Bool = true
    
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


//MARK:- 获取照片相册和相册集数组
extension YQImageManager {
    
    //获取照片相册集
    func getCameraRollAlbum(isAllowPickVideo: Bool, isAlowPickImage: Bool, completion: ((_ albumModel: YQAlbumModel) -> ())?) {
        
        var model = YQAlbumModel()
        
        //设置筛选属性
        let option = PHFetchOptions()
        if !isAllowPickVideo {
            let predicate = NSPredicate(format: "PHAssetMediaTypeImage")
            option.predicate = predicate
        }
        
        if !isAlowPickImage {
            let predicate = NSPredicate(format: "PHAssetMediaTypeVideo")
            option.predicate = predicate
        }
        
        if !self.isSortAscendingByModifiationDate {
            //设置时间排序选项
            let sort = NSSortDescriptor(key: "modificationDate", ascending: self.isSortAscendingByModifiationDate)
            option.sortDescriptors = [sort]
        }
        
        //获取相册
        let smartAlbums: PHFetchResult<PHAssetCollection> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil)
        
        //循环遍历出PHFetchResult
        smartAlbums.enumerateObjects({ (object, index, stop) in
            
            if object.isKind(of: PHAssetCollection.self) {
                let albumName: NSString = object.localizedTitle as NSString!
                
                if self.isCameraRollAlbum(albumName: albumName) {
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: object, options: option)
                    model = self.getAlbumModel(fetchResult: fetchResult as! PHFetchResult<PHAssetCollection>, name: object.localizedTitle)
                    
                    //执行闭包，返回图片资源模型
                    if completion != nil {
                        completion!(model)
                    }
                }
            }
        })
    }
    
    
    //获取相册集数组
    func getAllAlbums(isAllowPickVideo: Bool, isAlowPickImage: Bool, completion: ((_ albumModels: [YQAlbumModel]) -> ())?) {
        
        //存放相册集的数组
        var albums = [YQAlbumModel]()
        
        //设置筛选属性
        let option = PHFetchOptions()
        if !isAllowPickVideo {
            let predicate = NSPredicate(format: "PHAssetMediaTypeImage")
            option.predicate = predicate
        }
        
        if !isAlowPickImage {
            let predicate = NSPredicate(format: "PHAssetMediaTypeVideo")
            option.predicate = predicate
        }
        
        if !self.isSortAscendingByModifiationDate {
            //设置时间排序选项
            let sort = NSSortDescriptor(key: "creationDate", ascending: self.isSortAscendingByModifiationDate)
            option.sortDescriptors = [sort]
        }
        
        //我的照片流
        let myPhotoStreamAlbum: PHFetchResult<AnyObject> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumMyPhotoStream, options: nil) as! PHFetchResult<AnyObject>
        
        let smartAlbum: PHFetchResult<AnyObject> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.smartAlbum, subtype: PHAssetCollectionSubtype.albumRegular, options: nil) as! PHFetchResult<AnyObject>
        
        let topLevelUserCollection: PHFetchResult<AnyObject> = PHCollectionList.fetchTopLevelUserCollections(with: nil) as! PHFetchResult<AnyObject>
        
        let syncedAlbum: PHFetchResult<AnyObject> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumSyncedAlbum, options: nil) as! PHFetchResult<AnyObject>
        
        let sharedAlbum: PHFetchResult<AnyObject> = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype: PHAssetCollectionSubtype.albumCloudShared, options: nil) as! PHFetchResult<AnyObject>
        
        let tempAlbums: [PHFetchResult<AnyObject>] = [myPhotoStreamAlbum, smartAlbum, topLevelUserCollection, syncedAlbum, sharedAlbum]
        
        for fetchResult in tempAlbums {
            
            fetchResult.enumerateObjects({ (object, index, stop) in
                
                // 过滤掉PHCollectionList类的的对象
                if !object.isKind(of: PHAssetCollection.self) { }
                if object.isKind(of: PHAssetCollection.self) {
                    
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: object as! PHAssetCollection, options: option)
                    // 过滤掉 <1 的集合
                    if fetchResult.count < 1 {}
                    let albumName: NSString = object.localizedTitle as NSString!
                    // 过滤掉已经被删除的图片
                    if albumName.contains("Deleted") || albumName.contains("最近删除") {}
                    
                    let model = self.getAlbumModel(fetchResult: fetchResult as! PHFetchResult<PHAssetCollection>, name: albumName as String)
                    
                    if self.isCameraRollAlbum(albumName: albumName) {
                        albums.insert(model, at: 0)
                    } else {
                        albums.append(model)
                    }
                }
            })
        }
        
        //执行闭包，返回相册集模型数组
        if (completion != nil) && !albums.isEmpty {
            completion!(albums)
        }
    }
    
}

extension YQImageManager {
    
    //根据相册名称判断是否是相机相册
    func isCameraRollAlbum(albumName: NSString) -> Bool {
        
        var versionStr: NSString = UIDevice.current.systemVersion as NSString
        versionStr.replacingOccurrences(of: ".", with: "")
        
        if versionStr.length <= 1{
            versionStr = versionStr.appending("00") as NSString
        } else {
            versionStr = versionStr.appending("0") as NSString
        }
        
        return albumName.isEqual(to: "Camera Roll") || albumName.isEqual(to: "相机胶卷") || albumName.isEqual(to: "所有照片") || albumName.isEqual(to: "All Photos")
    }
    
    //根据一个相册创建一个相册模型
    func getAlbumModel(fetchResult: PHFetchResult<PHAssetCollection>, name: String?) -> YQAlbumModel {
        
        let model = YQAlbumModel()
        model.result = fetchResult
        model.name = name!
        model.count = fetchResult.count
        
        return model
    }
}
