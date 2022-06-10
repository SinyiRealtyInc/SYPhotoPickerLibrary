//
//  SYPhotoModel.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/25.
//

import Photos

struct AlbumFolder {
    
    var title: String
    var assets: PHFetchResult<PHAsset>
    var count: Int
    var isSelect: Bool
}

struct AlbumData {
    
    var assets: PHAsset
    var isSelect: Bool
    var selectTitle: String
}
