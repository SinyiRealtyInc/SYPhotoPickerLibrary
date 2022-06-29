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
    
    #warning("Cache 待優化")
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
    
    deinit {
        #warning("Cache 待優化")
        //imageCache.removeAllObjects()
        
        SYPhotoPickerHelper.weakInstance = nil
    }
    
    /// 設定略縮圖的大小
    /// - Parameter value: 大小, 上限 = 100
    public func setupPhotoThumbnailSize(value: CGFloat) {
        
        let density = UIScreen.main.scale
        let result = min(abs(value), 100)
        photoThumbnailSize = CGSize(width: result * density, height: result * density)
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
        let status = PHPhotoLibrary.authorizationStatus()
        
        switch status {
        case .restricted, .denied:
            didDenied?()
            return
        case .authorized:
            didAuthorized?()
            return
        default:
            break
        }
        
        if #available(iOS 14, *) {
            switch status {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { _ in
                    DispatchQueue.main.async {
                        requestPermission(didAuthorized: didAuthorized,
                                          didLimited: didLimited,
                                          didDenied: didDenied)
                    }
                }
            case .limited:
                didLimited?()
            default:
                break
            }
        } else {
            PHPhotoLibrary.requestAuthorization { _ in
                DispatchQueue.main.async {
                    requestPermission(didAuthorized: didAuthorized,
                                      didLimited: didLimited,
                                      didDenied: didDenied)
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
                                                isSelected: false)) })
        return album
    }
    
    /// 取得照片略酥酡
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - requestID: 請求識別碼
    ///   - completion: 完成後回調
    /// - Returns: PHImageRequestID
    public func fetchThumbnail(form asset: PHAsset,
                               requestID: Int,
                               completion: @escaping (_ image: UIImage) -> Swift.Void) -> PHImageRequestID? {
        
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = false
        
        if requestID != 0 {
            imageManager.cancelImageRequest(Int32(requestID))
        }
        
        let id = imageManager.requestImage(
            for: asset,
            targetSize: photoThumbnailSize,
            contentMode: .aspectFill,
            options: requestOptions,
            resultHandler: { (result, info) in
                guard let image = result else { return }
            
                completion(image)
            })
        
        return id
    }
    
    public func startCacheImage(prefetchItemsAt assets: [PHAsset]) {
        
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isSynchronous = false
        
        imageManager.startCachingImages(for: assets,
                                           targetSize: photoThumbnailSize,
                                           contentMode: .aspectFill,
                                           options: requestOptions)
    }
    
    public func stopCacheImage(cancelPrefetchingForItemsAt assets: [PHAsset]) {
        
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isSynchronous = false
        
        imageManager.stopCachingImages(for: assets,
                                          targetSize: photoThumbnailSize,
                                          contentMode: .aspectFill,
                                          options: requestOptions)
    }
}
