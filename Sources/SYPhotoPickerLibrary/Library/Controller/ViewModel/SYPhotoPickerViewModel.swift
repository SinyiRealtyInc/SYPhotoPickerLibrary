//
//  SYPhotoPickerViewModel.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/24.
//

import Foundation
import Photos

protocol SYPhotoPickerViewModelDelegate: SYBaseViewModelDelegate {

    func updateAlbumTitleView(text: String)
    func updateAlbumTitleView(isRotateImage: Bool)
    func updateBarRightItem(title: String, isEnable: Bool)
    func updatePhotoCollectionViewCell(indexPath: IndexPath, isSelect: Bool, selectTitle: String)
    func updateAlbumTableView(isHidden: Bool)
    
    func collectionViewReloadItems(indexPath: [IndexPath])
    func collectionViewReloadData()
    func tableViewReloadData()
    
    func photoPickerDidSelect(asset: PHAsset)
    func photoPickerDidDeselect(asset: PHAsset)
    func photoPickerConfirm(assets: [PHAsset])
    func photoPickerDismiss()
    func photoPickerLimitReached()
}

class SYPhotoPickerViewModel: SYBaseViewModel {
    
    weak var delegate: SYPhotoPickerViewModelDelegate?
    private var settings: SYPhotoPickerSetting?
    private var albumFolders: [AlbumFolder] = []
    private var albumSelectIndex: Int = 0
    private var selectedPhotos: [PHAsset] = []
    private var isHiddenAlbum = true
}

// MARK: - Interface Methods

extension SYPhotoPickerViewModel {
    
    func initial(settings: SYPhotoPickerSetting?) {

        loadAlbums()
        self.settings = settings
        guard let selectedPhotos = settings?.selectedPhotos else { return }
        self.selectedPhotos = selectedPhotos
        barRightItemCheck()
    }
    
    func barLeftItemTouchUpInside() {
        
        delegate?.photoPickerDismiss()
    }
    
    func barRightItemTouchUpInside() {
        
        guard selectedPhotos.count > 0 else { return }
        delegate?.photoPickerConfirm(assets: selectedPhotos)
    }
    
    func albumButtonTouchUpInside() {
    
        updateAlbumTableView(isRotateImage: false)
    }
}

// MARK: - UICollectionView Interface Methods

extension SYPhotoPickerViewModel {
    
    func getNumberOfItems() -> Int {
        
        guard albumFolders.count > 0 else { return 0 }
        let resultAsset = albumFolders[albumSelectIndex].assets
        return resultAsset.count
    }
    
    func getItemData(indexPath: IndexPath) -> AnyObject {
        
        guard albumFolders.count > 0 else { return "" as AnyObject }
        let resultAsset = albumFolders[albumSelectIndex].assets
        let asset = resultAsset[indexPath.row]
        let isSelect = selectedPhotos.contains(asset)
        var selectTitle = ""
        if let index = selectedPhotos.firstIndex(of: asset) {
            selectTitle = "\(index + 1)"
        }
        let data = AlbumData(assets: asset, isSelect: isSelect, selectTitle: selectTitle)
        return (data, settings) as AnyObject
    }
    
    func getPrefetchItemsData(indexPaths: [IndexPath]) -> [PHAsset] {
    
        let resultAsset = albumFolders[albumSelectIndex].assets
        let assets = indexPaths.compactMap({ resultAsset[$0.item] })
        return assets
    }
    
    func collectionViewDidSelect(indexPath: IndexPath) {
        
        guard albumFolders.count > 0 else { return }
        let resultAsset = albumFolders[albumSelectIndex].assets
        let asset = resultAsset[indexPath.row]
        if let index = selectedPhotos.firstIndex(of: resultAsset[indexPath.row]) {
            selectedPhotos.remove(at: index)
            delegate?.updatePhotoCollectionViewCell(indexPath: indexPath, isSelect: false, selectTitle: "")
            delegate?.photoPickerDidDeselect(asset: asset)
            updateCollectionViewData(index: index, resultAsset: resultAsset)
        } else {
            guard photoLimitCountCheck() else { return }
            selectedPhotos.append(asset)
            let title = String(selectedPhotos.count)
            delegate?.updatePhotoCollectionViewCell(indexPath: indexPath, isSelect: true, selectTitle: title)
            delegate?.photoPickerDidSelect(asset: asset)
        }
        barRightItemCheck()
    }
}

// MARK: - UITableView Interface Methods

extension SYPhotoPickerViewModel {

    func numberOfRowsInSection() -> Int {
        
        return albumFolders.count
    }
    
    func getCellData(indexPath: IndexPath) -> AnyObject {
        
        return (albumFolders[indexPath.row], settings) as AnyObject
    }
    
    func tableViewDidSelectRowAt(indexPath: IndexPath) {
     
        let fristData = albumFolders[indexPath.row]
        albumSelectIndex = indexPath.row
        delegate?.collectionViewReloadData()
        delegate?.updateAlbumTitleView(text: fristData.title)
        updateAlbumTableView(isRotateImage: true)
    }
}

// MARK: - Private Methods

extension SYPhotoPickerViewModel {
    
    private func loadAlbums() {

        albumFolders = SYPhotoPickerHelper.shared.fetchPhotos()
        
        guard albumFolders.count > 0 else { return }
        let fristData = albumFolders[albumSelectIndex]
        delegate?.updateAlbumTitleView(text: fristData.title)
        delegate?.collectionViewReloadData()
        delegate?.tableViewReloadData()
    }
    
    private func barRightItemCheck() {
        
        guard let settings = settings else { return }
        let isShowCount = selectedPhotos.count > 0
        let title = isShowCount ? settings.rightBarTitle + "(\(selectedPhotos.count))" : settings.rightBarTitle
        delegate?.updateBarRightItem(title: title, isEnable: isShowCount)
    }
    
    private func photoLimitCountCheck() -> Bool {
        
        guard let settings = settings, settings.limitCount <= selectedPhotos.count else { return true }
        delegate?.photoPickerLimitReached()
        return false
    }
    
    private func updateCollectionViewData(index: Int, resultAsset: PHFetchResult<PHAsset>) {
    
        guard let settings = settings, settings.photoSelectStyle == .string else { return }
        var updateIndexPath = [IndexPath]()
        let updateData = selectedPhotos[index...]
        for updateAsset in updateData {
            let updateIndex = resultAsset.index(of: updateAsset)
            updateIndexPath.append(IndexPath(item: updateIndex, section: 0))
        }
        guard updateIndexPath.count > 0 else { return }
        delegate?.collectionViewReloadItems(indexPath: updateIndexPath)
    }
    
    private func updateAlbumTableView(isRotateImage: Bool) {
        
        isHiddenAlbum = !isHiddenAlbum
        delegate?.updateAlbumTableView(isHidden: isHiddenAlbum)
        delegate?.updateAlbumTitleView(isRotateImage: isRotateImage)
    }
}
