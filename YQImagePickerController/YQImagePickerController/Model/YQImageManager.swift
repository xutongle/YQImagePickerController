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
    
    //当前应用的授权状态
    var authorizationStatus: PHAuthorizationStatus {
        
        return PHPhotoLibrary.authorizationStatus()
    }
    
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



//MARK:- 获取照片相册和相册集数组, 资源数组
extension YQImageManager {
    
    //获取照片相册模型
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
                    model = self.getAlbumModel(fetchResult: fetchResult, name: object.localizedTitle)!
                    
                    //执行闭包，返回图片资源模型
                    if completion != nil {
                        completion!(model)
                    }
                }
            }
        })
    }
    
    
    //获取所有的相册集
    func getAllAlbumModels(isAllowPickVideo: Bool, isAlowPickImage: Bool, completion: ((_ albumModels: [YQAlbumModel]) -> ())?) {
        
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
                if !object.isKind(of: PHAssetCollection.self) {
                    
                    //                    let shouldStop: ObjCBool = true
                    //                     stop.initialize(to: shouldStop)
                }
                
                if object.isKind(of: PHAssetCollection.self) {
                    
                    let fetchResult: PHFetchResult = PHAsset.fetchAssets(in: object as! PHAssetCollection, options: option)
                    // 过滤掉 <1 的集合
                    if fetchResult.count < 1 {
                        
                        //let shouldStop: ObjCBool = true// true or false ...
                        //stop.initialize(to: shouldStop)
                    }
                    
                    let albumName: NSString = object.localizedTitle as NSString!
                    // 过滤掉已经被删除的图片
                    if albumName.contains("Deleted") || albumName.contains("最近删除") {}
                    
                    let model = self.getAlbumModel(fetchResult: fetchResult, name: albumName as String)
                    
                    if self.isCameraRollAlbum(albumName: albumName) {
                        albums.insert(model!, at: 0)
                    } else {
                        albums.append(model!)
                    }
                }
            })
        }
        
        //执行闭包，返回相册集模型数组
        if (completion != nil) && !albums.isEmpty {
            completion!(albums)
        }
    }
    
    
    //从一个相册中获取该相册所有的资源模型
    func getAssetModels(fetchResult: PHFetchResult<AnyObject>, isAllowPickingVideo: Bool, isAllowPickingImage: Bool, completion: ((_ assetModels: [YQAssetModel]) -> ())?) {
        
        //存放资源的数组
        var assetModels = [YQAssetModel]()
        
        fetchResult.enumerateObjects({ (objc, index, stop) in
            
            let model = self.getAssetModel(asset: objc as! PHAsset, isAllowPickingVideo: isAllowPickingVideo, isAllowPickingImage: isAllowPickingImage)
            
            if model != nil {
                assetModels.append(model!)
            }
            
            if completion != nil {
                completion!(assetModels)
            }
        })
    }
    
    //从某个相册中获取指定下标的资源模型
    func getAssetModel(fetchResult: PHFetchResult<AnyObject>, index: NSInteger, isAllowPickingVideo: Bool, isAllowPickingImage: Bool, completion: ((_ assetModel: YQAssetModel?) -> ())?) {
        
        var asset = PHAsset()
        
        //判断异常，返回nil
        do {
            try asset = fetchResult[index] as! PHAsset
            
        } catch {
            if completion != nil {
                completion!(nil)
            }
        }
        
        let model = self.getAssetModel(asset: asset, isAllowPickingVideo: isAllowPickingVideo, isAllowPickingImage: isAllowPickingImage)
        completion!(model)
    }
    
    
    func getImage(asset: PHAsset, imageWidth: CGFloat, completion: @escaping (_ image: UIImage, _ info: Dictionary<String, Any>, _ isDegraded: Bool) -> ()) -> PHImageRequestID {
        
        return self.getImageID(asset: asset, imageWidth: imageWidth, isNetWorkAccessAllowed: true, completion: completion, progressHandler: nil)
    }
    
    //得到指定宽度的图片/从Cloud中获取图片
    func getImageID(asset: PHAsset, imageWidth: CGFloat, isNetWorkAccessAllowed: Bool, completion: ((_ image: UIImage, _ info: Dictionary<String, Any>, _ isDegraded: Bool) -> ())?, progressHandler: ((_ progress: Double, _ error: Error?, _ stop: UnsafeMutablePointer<ObjCBool>, _ info: Dictionary<String, Any>) -> ())?) -> PHImageRequestID {
        
        var imageSize = CGSize.zero
        
        if (imageWidth < YQScreenWidth && imageWidth < self.imagePreviewMaxWidth) {
            imageSize = YQAssetGridThumbnailSize
            
        } else {
            
            let aspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            let pixelWidth = imageWidth * YQScreenScale;
            let pixelHeight = pixelWidth / aspectRatio;
            imageSize = CGSize(width: pixelWidth, height: pixelHeight)
        }
        
        let option = PHImageRequestOptions()
        option.resizeMode = PHImageRequestOptionsResizeMode.fast;
        
        //设置各种条件获取到一张图片的id
        let imageRequestID = PHImageManager.default().requestImage(for: asset, targetSize: imageSize, contentMode: PHImageContentMode.aspectFill, options: option) { (image: UIImage?, info: Dictionary?) in
            
            //类型转换
            let tempInfo = info as! [String : Any]
            let isCancel = tempInfo[PHImageCancelledKey] as! Bool
            let hasError = tempInfo[PHImageErrorKey] as! Bool
            let isDegraded = tempInfo[PHImageResultIsDegradedKey] as! Bool
            //获取完成的标志
            let downloadCompleted = !isCancel && !hasError
            
            if (downloadCompleted && image != nil) {
                
                let fixedImage = self.fixOrientation(originImage: image!)
                if completion != nil {
                    completion!(fixedImage, info as! Dictionary<String, Any>, isDegraded)
                }
            }
            
            //从iCloud下载图片
            let isCloud = tempInfo[PHImageResultIsInCloudKey] as! Bool
            if (isCloud && (image != nil) && isNetWorkAccessAllowed) {
                
                let option  = PHImageRequestOptions()
                option.progressHandler = {(_ progress: Double, _ error: Error?, _ stop: UnsafeMutablePointer<ObjCBool>, _ info: [AnyHashable : Any]?) in
                    
                    DispatchQueue.main.async {
                        if progressHandler != nil {
                            progressHandler!(progress, error, stop, info as! Dictionary<String, Any>)
                        }
                    }
                    
                    option.isNetworkAccessAllowed = true
                    option.resizeMode = PHImageRequestOptionsResizeMode.fast
                    PHImageManager.default().requestImageData(for: asset, options: option, resultHandler: { (imageData, dataUTI, orientation, info) in
                        
                        var image = UIImage.init(data: imageData!, scale: 0.1)
                        image = self.scale(image!, toSize: imageSize)
                        
                        if image != nil {
                            image = self.fixOrientation(originImage: image!)
                            
                            if completion != nil {
                                completion!(image!, info as! Dictionary<String, Any>, isDegraded)
                            }
                        }
                        
                    })
                }
                
            }
        }
        return imageRequestID
    }
    
    
    //从指定相册中获取封面图
    func getCoverImage(albummodel: YQAlbumModel, completion: ((_ image: UIImage) -> ())?) {
        
        var asset = (albummodel.result?.lastObject)! as PHAsset
        
        if !self.isSortAscendingByModifiationDate {
            asset = (albummodel.result?.firstObject)! as PHAsset
        }
        
        self.getImage(asset: asset, imageWidth: CGFloat(80)) { (image, info, isDegraded) in
            if completion != nil {
                completion!(image)
            }
        }
    }
    
    
    //从指定相册中获取原图
    func getoriginalImage(asset: PHAsset, completion: ((_ image: UIImage, _ info: Dictionary<String, Any>) -> ())?) {
        
        return self.getOriginalImage(asset: asset, newcompletion: { (image, info, isDegraded) in
            if completion != nil {
                completion!(image, info)
            }
        })
    }
    
    
    //从指定资源中获取原图
    func getOriginalImage(asset: PHAsset, newcompletion: ((_ image: UIImage, _ info: Dictionary<String, Any>, _ isDegraded: Bool) -> ())?) {
        
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: PHImageContentMode.aspectFit, options: option) { (image: UIImage?, info: Dictionary?) in
            
            let tempInfo = info as! [String : Any]
            let isCancel = tempInfo[PHImageCancelledKey] as! Bool
            let hasError = tempInfo[PHImageErrorKey] as! Bool
            let isDegraded = tempInfo[PHImageResultIsDegradedKey] as! Bool
            //获取完成的标志
            let downloadCompleted = !isCancel && !hasError
            
            if (downloadCompleted && image != nil) {
                
                let fixedImage = self.fixOrientation(originImage: image!)
                if newcompletion != nil {
                    newcompletion!(fixedImage, info as! Dictionary<String, Any>, isDegraded)
                }
            }
        }
    }
    
    func getOriginalImageData(asset: PHAsset, completion: ((_ data: NSData, _ info: Dictionary<String, Any>, _ isDegraded: Bool) ->())?) {
        
        let option = PHImageRequestOptions()
        option.isNetworkAccessAllowed = true
        PHImageManager.default().requestImageData(for: asset, options: option) { (imageata, dataUTI, orientation, info: Dictionary) in
            
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
    func getAlbumModel(fetchResult: PHFetchResult<PHAsset>, name: String?) -> YQAlbumModel? {
        
        let model = YQAlbumModel()
        model.result = fetchResult
        model.name = name!
        model.count = fetchResult.count
        
        return model
    }
    
    
    //根据一个资源创建一个资源模型
    func getAssetModel(asset: PHAsset, isAllowPickingVideo: Bool, isAllowPickingImage: Bool) -> YQAssetModel? {
        
        var type = YQAssetModelType.photo
        
        //判断资源的类型是 ：普通图片、GIF动图、视频、音频
        switch asset.mediaType {
            
        case .image:
            
            let filename = asset.value(forKey: "filename") as! String
            if filename.hasSuffix("GIF") {
                type = YQAssetModelType.gif
            }
            
        case .video:
            
            type = YQAssetModelType.video
            
        case .audio:
            
            type = YQAssetModelType.audio
            
        default:
            
            type = YQAssetModelType.photo
        }
        
        //判断是否可以选择对应类型的资源
        if isAllowPickingImage && type == YQAssetModelType.photo {
            return nil
        }
        
        if isAllowPickingVideo && type == YQAssetModelType.video {
            return nil
        }
        
        //创建资源模型
        let model = YQAssetModel(asset: asset, type: type)
        return model
    }
    
    //根据一个资源数组创建一个资源模型数组
    func getAssetModels(asset: PHAsset, isAllowPickingVideo: Bool, isAllowPickingImage: Bool) -> YQAssetModel? {
        
        var type = YQAssetModelType.photo
        
        //判断资源的类型是 ：普通图片、GIF动图、视频、音频
        switch asset.mediaType {
            
        case .image:
            
            let filename = asset.value(forKey: "filename") as! String
            if filename.hasSuffix("GIF") {
                type = YQAssetModelType.gif
            }
            
        case .video:
            
            type = YQAssetModelType.video
            
        case .audio:
            
            type = YQAssetModelType.audio
            
        default:
            
            type = YQAssetModelType.photo
        }
        
        //判断是否可以选择对应类型的资源
        if isAllowPickingImage && type == YQAssetModelType.photo {
            return nil
        }
        
        if isAllowPickingVideo && type == YQAssetModelType.video {
            return nil
        }
        
        //创建资源模型
        let model = YQAssetModel(asset: asset, type: type)
        return model
    }
    
    //根据一张图片通过修正图片转向获得新的图片
    func fixOrientation(originImage: UIImage) -> UIImage {
        
        if !isNeedFixOrientation {
            return originImage
        }
        
        if (originImage.imageOrientation == UIImageOrientation.up) {
            return originImage;
        }
        
        var transform: CGAffineTransform = CGAffineTransform.identity
        
        switch (originImage.imageOrientation) {
            
        case .down, .left, .right: break
            
        case .downMirrored:
            transform = transform.translatedBy(x: originImage.size.width, y: originImage.size.height);
            transform = transform.rotated(by: CGFloat(M_PI));
            break;
            
        case .leftMirrored:
            transform = transform.translatedBy(x: originImage.size.width, y: 0);
            transform = transform.rotated(by: CGFloat(M_PI_2));
            break;
            
        case .rightMirrored:
            transform = transform.translatedBy(x: 0, y: originImage.size.height);
            transform = transform.rotated(by: -(CGFloat)(M_PI_2));
            break;
            
        default:
            break;
        }
        
        //重绘
        let perBits = (originImage as! CGImage).bitsPerComponent
        let color = (originImage as! CGImage).colorSpace
        let bitmap = (originImage as! CGImage).bitmapInfo
        let ctx = CGContext(data: nil, width: Int(originImage.size.width), height: Int(originImage.size.height), bitsPerComponent: perBits, bytesPerRow: 0, space: color!, bitmapInfo: bitmap.rawValue)
        
        ctx!.concatenate(transform)
        
        switch originImage.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            
            let rect = CGRect(x: 0, y: 0, width: originImage.size.height, height: originImage.size.height)
            ctx?.draw(originImage.cgImage!, in: rect, byTiling: true)
            break
            
        default:
            break
        }
        
        let cgimage = ctx!.makeImage()
        let image = UIImage.init(cgImage: cgimage!)
        return image
    }
    
    //将图片缩放到指定大小
    func scale(_ image: UIImage, toSize size: CGSize) -> UIImage {
        
        if (image.size.width > size.width) {
            UIGraphicsBeginImageContext(size);
            image.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
            UIGraphicsEndImageContext();
            return newImage;
            
        } else {
            return image;
        }
    }
    
}
