//
//  SYPhotoPickerHelper.swift
//  SYPhotoPickerLibrary
//
//  Created by Ray on 2022/1/24.
//

import UIKit
import Photos

/// 處理權限、相片讀取幫助類
class SYPhotoPickerHelper {
    
    private static var weakInstance: SYPhotoPickerHelper?
    
    static var shared: SYPhotoPickerHelper {
        get {
            if let instance = weakInstance {
                return instance
            } else {
                let newInstance = SYPhotoPickerHelper()
                weakInstance = newInstance
                return newInstance
            }
        }
    }
    
    /// Photo manager object
    private(set) var imageManager: PHCachingImageManager
    private(set) var requestOptions: PHImageRequestOptions
    private(set) var photoThumbnailSize: CGSize = .zero
    private var imageCache: NSCache<AnyObject, UIImage> = NSCache()
    
    private init() {
        
        imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = false
        
        requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = false
        
        let density = UIScreen.main.scale
        photoThumbnailSize = CGSize(width: 100 * density, height: 100 * density)
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        imageManager.stopCachingImagesForAllAssets()
    }
    
    func destroy() {
        
        imageCache.removeAllObjects()
        SYPhotoPickerHelper.weakInstance = nil
    }
    
    public func setupPhotoThumbnailSize(width: CGFloat) {
        
        let density = UIScreen.main.scale
        let value = width <= 100 && width > 0 ? width : 100
        photoThumbnailSize = CGSize(width: value * density, height: value * density)
    }
}

// MARK: - AuthorizationStatus

extension SYPhotoPickerHelper {
    
    /// 使用者允許讀取相簿 callback
    typealias DidAuthorized = () -> Swift.Void
    
    
    /// 使用者允許讀取相簿但僅顯示部分照片
    typealias DidLimited = () -> Swift.Void
    
    /// 使用者不允許讀取相簿 callback
    typealias DidDenied = () -> Swift.Void
    
    /// 請求相簿權限
    /// - Parameters:
    ///   - didAuthorized: 使用者允許讀取相簿 callback
    ///   - didLimited: 使用者允許讀取相簿但僅顯示部分照片
    ///   - didDenied: 使用者不允許讀取相簿 callback
    static public func requestPermission(didAuthorized: DidAuthorized?,
                                         didLimited: DidLimited?,
                                         didDenied: DidDenied?) {
        
        DispatchQueue.main.async {
            
            let status = PHPhotoLibrary.authorizationStatus()
            if #available(iOS 14, *), status == .limited { didLimited?() }
            if status == .denied || status == .restricted { didDenied?() }
            if status == .authorized { didAuthorized?() }
            
            guard status == .notDetermined else { return }
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                    if status == .authorized { didAuthorized?() }
                    if status == .limited { didLimited?() }
                    if status == .denied || status == .restricted { didDenied?() }
                }
            } else {
                PHPhotoLibrary.requestAuthorization { (status) in
                    if status == .authorized { didAuthorized?() }
                    if status == .denied || status == .restricted { didDenied?() }
                }
            }
        }
    }
}

// MARK: - FetchPhoto

extension SYPhotoPickerHelper {
    
    public func fetchPhotos() -> [AlbumFolder] {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary
        
        // Smart album
        let smartAlbums = PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                                  subtype: .albumRegular,
                                                                  options: fetchOptions)
        // DropBox、Instagram ... else
        let albums = PHAssetCollection.fetchAssetCollections(with: .album,
                                                             subtype: .albumRegular,
                                                             options: fetchOptions)
        
        var data: [(collection: PHAssetCollection, assets: PHFetchResult<PHAsset>)] = []
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        for i in 0 ..< smartAlbums.count {
            let collection = smartAlbums[i]
            let assets = PHAsset.fetchAssets(in: collection , options: options)
            guard assets.count > 0 else { continue }
            data.append((collection, assets))
        }
        for i in 0 ..< albums.count {
            let collection = albums[i]
            let assets = PHAsset.fetchAssets(in: collection , options: options)
            guard assets.count > 0 else { continue }
            data.append((collection, assets))
        }
        data.sort { $0.assets.count > $1.assets.count }
        
        var album = [AlbumFolder]()
        data.forEach({ album.append(AlbumFolder(title: $0.collection.localizedTitle ?? "",
                                                assets: $0.assets,
                                                count: $0.assets.count,
                                                isSelect: false)) })
        return album
    }
    
    public func fetchThumbnail(form asset: PHAsset,
                               requestID: Int,
                               completion: @escaping (_ image: UIImage) -> Swift.Void) -> PHImageRequestID? {
        
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = false
        
//        if let image = imageCache.object(forKey: asset) {
//            completion(image)
//            return nil
//        }
        if requestID != 0 {
            imageManager.cancelImageRequest(Int32(requestID))
        }
        let request = imageManager.requestImage(for: asset,
                                                   targetSize: photoThumbnailSize,
                                                   contentMode: .aspectFill,
                                                   options: requestOptions,
                                                   resultHandler: { (result, info) in
            guard let image = result else { return }
            //            self.imageCache.setObject(image, forKey: asset)
            completion(image)
        })
        return request
    }
    
    public func startCacheImage(prefetchItemsAt assets: [PHAsset]) {
        
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = false
        
        imageManager.startCachingImages(for: assets,
                                           targetSize: photoThumbnailSize,
                                           contentMode: .aspectFill,
                                           options: requestOptions)
    }
    
    public func stopCacheImage(cancelPrefetchingForItemsAt assets: [PHAsset]) {
        
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = false
        
        imageManager.stopCachingImages(for: assets,
                                          targetSize: photoThumbnailSize,
                                          contentMode: .aspectFill,
                                          options: requestOptions)
    }
}
