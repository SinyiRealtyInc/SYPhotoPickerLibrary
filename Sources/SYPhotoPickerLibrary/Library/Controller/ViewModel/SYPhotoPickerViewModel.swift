//
//  SYPhotoPickerViewModel.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/24.
//

import Foundation
import Photos

protocol SYPhotoPickerViewModelDelegate: AnyObject {
    
    /// 更新標題名稱
    func updateNavigationTitle(for text: String?)
    
    /// 更新標題圖示方向
    func updateNavigationArrow(for open: Bool)
    
    /// 更新右側BarItem標題及啟用狀態
    func updateBarRightItem(title: String, isEnable: Bool)
    
    /// 顯示或隱藏相簿挑選清單
    func showingAlbumList(isHidden: Bool)
    
    /// 更新SYPhotoCell狀態
    func updatePhotoCollectionViewCell(indexPath: IndexPath, isSelect: Bool, selectTitle: String)
    
    /// 更新局部Item狀態
    func collectionViewReloadItems(indexPath: [IndexPath])
    
    /// 更新CollectionView內容
    func collectionViewReloadData()
    
    /// 更新TableView內容
    func tableViewReloadData()
    
    /// 照片已被選取
    func photoPickerDidSelect(asset: PHAsset)
    
    /// 照片取消選曲
    func photoPickerDidDeselect(asset: PHAsset)
    
    /// 選定照片
    func photoPickerConfirm(assets: [PHAsset])
    
    /// 離開照片挑選器
    func photoPickerDismiss()
    
    /// 照片挑選數量達到上限
    func photoPickerDidLimit()
}

class SYPhotoPickerViewModel {
    
    private var settings: SYPhotoPickerSetting = SYPhotoPickerSetting()

    /// 相簿資料集, default = []
    private var albumFolders: [AlbumFolder] = []
    
    /// 目前相簿索引值, default = 0
    private var albumSelectIndex: Int = 0

    /// 選取照片集, default = []
    private var selectedPhotos: [PHAsset] = []

    /// 相簿挑選器是否隱藏, default = true
    private var isHiddenAlbum: Bool = true

    weak var delegate: SYPhotoPickerViewModelDelegate?
    
    deinit {
        #if DEBUG
        print("Deinit: \(self)")
        #endif
    }
}

// MARK: - Interface Methods

extension SYPhotoPickerViewModel {
    
    /// 初始化 ViewModel
    /// - Parameter settings: SYPhotoPickerSetting
    func initial(settings: SYPhotoPickerSetting) {
        
        loadAlbums()
        
        self.settings = settings
        selectedPhotos = settings.selectedPhotos
        
        updateBarRightItem()
    }
    
    /// 離開照片挑選器
    func pickerDismiss() {
        
        delegate?.photoPickerDismiss()
    }
    
    /// 確認挑選照片
    func pickerConfirm() {
        
        guard selectedPhotos.isEmpty == false else { return }
        
        delegate?.photoPickerConfirm(assets: selectedPhotos)
    }
    
    /// 開啟相簿選擇清單
    func showPhotoAlbums() {
        updateNavigationArrow(open: !isHiddenAlbum)
    }
    
    /// 載入照片
    func loadAlbums() {

        albumFolders = SYPhotoPickerHelper.shared.fetchPhotos()
        
        guard albumFolders.count > 0 else { return }
        
        delegate?.updateNavigationTitle(for: albumFolders[albumSelectIndex].title)
        delegate?.collectionViewReloadData()
        delegate?.tableViewReloadData()
    }
}

// MARK: - Private Methods

extension SYPhotoPickerViewModel {
    
    /// 更新右側BarButton狀態
    private func updateBarRightItem() {
        
        guard let title = settings.rightBarTitle
        else {
            return
        }
        
        let count = selectedPhotos.count
        let barTitle = count > 0 ? "\(title) (\(count))" : title
        
        delegate?.updateBarRightItem(title: barTitle, isEnable: count > 0)
    }
    
    /// 更新局部Item狀態
    /// - Parameters:
    ///   - index: 索引
    ///   - assets: PHFetchResult<PHAsset>
    private func updateCollectionViewData(index: Int, assets: PHFetchResult<PHAsset>) {
    
        guard settings.photoSelectStyle == .number
        else {
            return
        }
        
        var updateIndexPath = [IndexPath]()
        let updateData = selectedPhotos[index...]
        
        for updateAsset in updateData {
            let updateIndex = assets.index(of: updateAsset)
            updateIndexPath.append(IndexPath(item: updateIndex, section: 0))
        }
        
        guard updateIndexPath.count > 0 else { return }
        
        delegate?.collectionViewReloadItems(indexPath: updateIndexPath)
    }
    
    /// 更新標題圖示方向
    /// - Parameter open: 相簿挑選清單是否顯示
    private func updateNavigationArrow(open: Bool) {
        isHiddenAlbum.toggle()
        
        delegate?.showingAlbumList(isHidden: isHiddenAlbum)
        delegate?.updateNavigationArrow(for: open)
    }
}

// MARK: - UITableView Interface Methods

extension SYPhotoPickerViewModel {
    
    /// 取得相簿數量
    /// - Returns: 數量
    func getAlbumFolderCount() -> Int {
        
        return albumFolders.count
    }
    
    /// 依照索引取得 Album Folder
    /// - Parameter indexPath: 索引
    /// - Returns: AlbumFolder Model
    func getFolder(for indexPath: IndexPath) -> AlbumFolder {
        
        return albumFolders[indexPath.row]
    }
    
    /// 點擊 Album Folder 索引
    /// - Parameter indexPath: 索引位置
    func tableViewDidSelectRowAt(indexPath: IndexPath) {
        let row: Int = indexPath.row
        
        albumSelectIndex = row
        updateNavigationArrow(open: !isHiddenAlbum)
        
        let folder = albumFolders[row]
        delegate?.updateNavigationTitle(for: folder.title)
        delegate?.collectionViewReloadData()
    }
}

// MARK: - UICollectionView Interface Methods

extension SYPhotoPickerViewModel {
    
    /// 取得照片數量
    /// - Returns: 數量
    func getPhotoCount() -> Int {
        
        guard albumFolders.isEmpty == false else { return 0 }
        
        let result = albumFolders[albumSelectIndex].assets
        
        return result.count
    }
    
    /// 取得照片
    /// - Parameter indexPath: 索引
    /// - Returns: AlbumData
    func getPhoto(for indexPath: IndexPath) -> AlbumData? {
        
        guard albumFolders.isEmpty == false else { return nil }
        
        let assets = albumFolders[albumSelectIndex].assets
        
        let asset = assets[indexPath.row]
        
        let isSelect = selectedPhotos.contains(asset)
        
        var selectTitle = ""
        
        if let index = selectedPhotos.firstIndex(of: asset) {
            selectTitle = "\(index + 1)"
        }

        return AlbumData(asset: asset, isSelected: isSelect, selectTitle: selectTitle)
    }
    
    /// 取得目前已挑選的照片
    /// - Parameter indexPaths: 索引
    /// - Returns: [PHAsset]
    func getPrefetchItemsData(indexPaths: [IndexPath]) -> [PHAsset] {
    
        let assets = albumFolders[albumSelectIndex].assets
        
        return indexPaths.compactMap({ assets[$0.item] })
    }
    
    /// 挑選照片
    /// - Parameter indexPath: 索引
    func collectionViewDidSelect(indexPath: IndexPath) {
        
        guard albumFolders.count > 0 else { return }
        
        let row = indexPath.row
        let assets = albumFolders[albumSelectIndex].assets
        let asset = assets[row]
        
        if let index = selectedPhotos.firstIndex(of: assets[row]) {
            selectedPhotos.remove(at: index)
            
            delegate?.updatePhotoCollectionViewCell(indexPath: indexPath,
                                                    isSelect: false,
                                                    selectTitle: "")
            delegate?.photoPickerDidDeselect(asset: asset)
            
            updateCollectionViewData(index: index, assets: assets)
        } else {
            guard settings.limitCount > selectedPhotos.count
            else {
                delegate?.photoPickerDidLimit()
                return
            }
            
            selectedPhotos.append(asset)
            
            delegate?.updatePhotoCollectionViewCell(indexPath: indexPath,
                                                    isSelect: true,
                                                    selectTitle: "\(selectedPhotos.count)")
            delegate?.photoPickerDidSelect(asset: asset)
        }
        
        updateBarRightItem()
    }
}
