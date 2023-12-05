//
//  SYPhotoPickerHelper.swift
//  SYPhotoPickerLibrary
//
//  Created by Ray on 2022/1/24.
//

import UIKit
import Photos

/// 處理權限、相片讀取幫助類
public class SYPhotoPickerHelper {
    
    private static var weakInstance: SYPhotoPickerHelper?
    
    public static var shared: SYPhotoPickerHelper {
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
    
    private init() {
        imageManager = PHCachingImageManager()
        imageManager.allowsCachingHighQualityImages = false
        
        requestOptions = PHImageRequestOptions()
        requestOptions.isNetworkAccessAllowed = true
        
        let density = UIScreen.main.scale
        photoThumbnailSize = CGSize(width: 100 * density, height: 100 * density)
        
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        imageManager.stopCachingImagesForAllAssets()
    }
    
    deinit {
        SYPhotoPickerHelper.weakInstance = nil
    }
}

// MARK: - AuthorizationStatus

extension SYPhotoPickerHelper {
    
    /// 使用者允許讀取相簿 callback
    public typealias DidAuthorized = () -> Swift.Void
    
    /// 使用者允許讀取相簿但僅顯示部分照片 callback，firstRequest：是否第一次詢問
    public typealias DidLimited = (_ firstRequest: Bool) -> Swift.Void
    
    /// 使用者不允許讀取相簿 callback
    public typealias DidDenied = () -> Swift.Void
    
    /// 請求相簿權限
    /// - Parameters:
    ///   - didAuthorized: 使用者允許讀取相簿回調
    ///   - didLimited: 使用者允許讀取相簿但僅顯示部分照片回調
    ///   - didDenied: 使用者不允許讀取相簿回調
    static public func requestPermission(didAuthorized: DidAuthorized?,
                                         didLimited: DidLimited?,
                                         didDenied: DidDenied?) {
        if #available(iOS 14.0, *) {
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization(for: .readWrite) { (status) in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            didAuthorized?()
                        case .limited:
                            didLimited?(true)
                        case .denied, .restricted:
                            didDenied?()
                        case .notDetermined:
                            // do nothing...
                            break
                        @unknown default:
                            break
                        }
                    }
                }
            case .authorized:
                didAuthorized?()
            case .limited:
                didLimited?(false)
            case .denied, .restricted:
                didDenied?()
            default:
                break
            }
        } else {
            switch PHPhotoLibrary.authorizationStatus() {
            case .notDetermined:
                PHPhotoLibrary.requestAuthorization { (status) in
                    DispatchQueue.main.async {
                        switch status {
                        case .authorized:
                            didAuthorized?()
                        case .denied, .restricted:
                            didDenied?()
                        default:
                            break
                        }
                    }
                }
            case .authorized:
                didAuthorized?()
            case .denied, .restricted:
                didDenied?()
            default:
                break
            }
        }
    }
}

// MARK: - Fetch Photo

extension SYPhotoPickerHelper {
    
    /// 取得相簿
    /// - Parameter fetchLimit: 相簿內取得張數
    /// - Returns: [AlbumFolder]
    func fetchPhotos(fetchLimit: Int) -> [AlbumFolder] {
        
        let fetchOptions = PHFetchOptions()
        fetchOptions.includeAssetSourceTypes = .typeUserLibrary

        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = fetchLimit < 1 ? 9999 : fetchLimit

        let albums = [
            PHAssetCollection.fetchAssetCollections(with: .smartAlbum,
                                                    subtype: .albumRegular,
                                                    options: fetchOptions),
            PHAssetCollection.fetchAssetCollections(with: .album,
                                                    subtype: .albumRegular,
                                                    options: fetchOptions)
        ]

        var data: [(collection: PHAssetCollection, assets: PHFetchResult<PHAsset>)] = []

        for album in albums {
            for i in 0 ..< album.count {
                let collection = album[i]
                let assets = PHAsset.fetchAssets(in: collection , options: options)
                if assets.count > 0 {
                    data.append((collection, assets))
                }
            }
        }

        data.sort { $0.assets.count > $1.assets.count }
        
        var album = [AlbumFolder]()
        data.forEach({ album.append(AlbumFolder(title: $0.collection.localizedTitle ?? "",
                                                assets: $0.assets,
                                                isSelected: false)) })
        return album
    }
    
    /// 取得照片略縮圖
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - requestID: 請求識別碼
    ///   - completion: 完成後回調
    /// - Returns: PHImageRequestID
    func fetchThumbnail(form asset: PHAsset,
                        requestID: Int,
                        completion: @escaping (_ image: UIImage) -> Swift.Void) -> PHImageRequestID {
        
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
    
    func startCacheImage(prefetchItemsAt assets: [PHAsset]) {
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isSynchronous = false
        
        imageManager.startCachingImages(for: assets,
                                        targetSize: photoThumbnailSize,
                                        contentMode: .aspectFill,
                                        options: requestOptions)
    }
    
    func stopCacheImage(cancelPrefetchingForItemsAt assets: [PHAsset]) {
        requestOptions.resizeMode = .fast
        requestOptions.deliveryMode = .fastFormat
        requestOptions.isSynchronous = false
        
        imageManager.stopCachingImages(for: assets,
                                       targetSize: photoThumbnailSize,
                                       contentMode: .aspectFill,
                                       options: requestOptions)
    }
    
    /// 取得圖片
    /// - Parameters:
    ///   - asset: PHAsset
    ///   - size: 圖片尺寸
    ///   - resizeMode: PHImageRequestOptionsResizeMode
    ///   - deliveryMode: PHImageRequestOptionsDeliveryMode
    ///   - isSynchronous: 是否要等待圖片處理完成 true = block the calling thread, otherwise false.
    ///   - completion: 完成後回調
    public func fetchImage(form asset: PHAsset,
                           size: CGSize,
                           resizeMode: PHImageRequestOptionsResizeMode = .exact,
                           deliveryMode: PHImageRequestOptionsDeliveryMode = .highQualityFormat,
                           isSynchronous: Bool = true,
                           completion: @escaping (_ image: UIImage?) -> Swift.Void) {
        
        requestOptions.resizeMode = .exact
        requestOptions.deliveryMode = .highQualityFormat
        requestOptions.isSynchronous = isSynchronous
        
        PHImageManager.default().requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFit,
            options: requestOptions,
            resultHandler: { (result, info) in
                
                guard let image = result else {
                    completion(nil)
                    return
                }
                
                completion(image)
            })
    }
}

// MARK: - Function

extension SYPhotoPickerHelper {
    
    /// 設定略縮圖的大小
    /// - Parameter value: 大小, 上限 = 100
    func setupPhotoThumbnailSize(value: CGFloat) {
        
        let density = UIScreen.main.scale
        let result = max(abs(value), 100)
        photoThumbnailSize = CGSize(width: result * density, height: result * density)
    }
    
    /// 取得檔名
    /// - Parameter asset: PHAsset
    /// - Returns: 檔名
    public func fetchImageName(from asset: PHAsset) -> String? {
        return PHAssetResource.assetResources(for: asset).first?.originalFilename
    }
    
    /// 取得檔案類型
    /// - Parameter asset: PHAsset
    /// - Returns: 檔案類型
    public func fetchImageUTI(from asset: PHAsset) -> String? {
        return PHAssetResource.assetResources(for: asset).first?.uniformTypeIdentifier
    }
}
