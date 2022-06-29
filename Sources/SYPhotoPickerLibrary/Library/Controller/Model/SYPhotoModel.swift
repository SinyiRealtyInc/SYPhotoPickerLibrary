//
//  SYPhotoModel.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/25.
//

import Photos

/// 照片資料夾
struct AlbumFolder {
    
    /// 資料夾名稱
    var title: String?
    
    /// 照片集
    var assets: PHFetchResult<PHAsset>
    
    /// 是否被選取
    var isSelected: Bool = false
    
    /// 數量
    var count: Int { assets.count }
}

/// 照片資料
struct AlbumData {
    
    /// PHAsset Model
    var asset: PHAsset
    
    /// 是否被選取
    var isSelected: Bool = false
    
    var selectTitle: String?
}
