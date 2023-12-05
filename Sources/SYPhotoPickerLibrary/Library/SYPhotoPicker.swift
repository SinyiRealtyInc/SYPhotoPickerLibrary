//
//  SYPhotoPicker.swift
//  SYPhotoPickerLibrary
//
//  Created by Ray on 2022/1/24.
//

import Foundation
import UIKit
import Photos

@objc public protocol SYPhotoPickerDelegate {
    
    /// 照片權限被拒
    @objc optional func photoPickerAuthorizedDenied()
    
    /// 照片已選取
    @objc optional func photoPickerDidSelect(asset: PHAsset)
    
    /// 照片取消選取
    @objc optional func photoPickerDidDeselect(asset: PHAsset)
    
    /// 選取數量達到上限
    @objc optional func photoPickerDidLimit()
    
    /// 確認所選照片
    @objc optional func photoPickerConfirm(assets: [PHAsset])
    
    /// 關閉照片挑選器
    @objc optional func photoPickerDismiss()
}

public final class SYPhotoPicker {
    
    /// 照片挑選器設定 Model
    public var settings: SYPhotoPickerSetting
    
    public weak var delegate: SYPhotoPickerDelegate?
    
    public init(type: SYPhotoPickerType) {
        settings = SYPhotoPickerSetting()
        
        setupPhotoPickerSetting(type: type)
    }
}

// MARK: - Private Method

extension SYPhotoPicker {
    
    private func setupPhotoPickerSetting(type: SYPhotoPickerType) {
        switch type {
        case .ta:
            setupTaSetting()
        case .im:
            setupImSetting()
        case .`default`:
            break
        }
    }
    
    private func setupTaSetting() {
        settings.statusBarStyle = .darkContent
        settings.barTintColor = .white
        settings.barTitleIconColor = SYColor.black2
        settings.leftBarTitle = nil
        settings.rightBarTitle = "確認"
        settings.leftBarImage = SYImage.close.image
        settings.rightBarImage = nil
        settings.limitCount = 21
        settings.numberForRow = 4
        settings.photoSelectStyle = .number
        settings.photoSelectBorderWidth = 2
        settings.photoSelectColor = SYColor.green
    }
    
    private func setupImSetting() {
        settings.statusBarStyle = .default
        settings.barTintColor = .white
        settings.barTitleIconColor = SYColor.black
        settings.leftBarTitle = nil
        settings.rightBarTitle = "傳送"
        settings.leftBarImage = SYImage.close.image
        settings.rightBarImage = nil
        settings.limitCount = 10
        settings.numberForRow = 4
        settings.photoSelectStyle = .number
        settings.photoSelectBorderWidth = 0
        settings.photoSelectColor = SYColor.green
    }
    
    private func showPhotoPicker(currentVC: UIViewController,
                                 modalPresentationStyle: UIModalPresentationStyle) {
        
        let vc = SYPhotoPickerVC(nibName: "SYPhotoPickerVC", bundle: .module)
        vc.settings = settings
        vc.delegate = delegate
        
        let nac = SYNavigationController(rootViewController: vc)
        nac.settings = settings
        nac.modalPresentationStyle = modalPresentationStyle
        
        currentVC.present(nac, animated: true, completion: nil)
    }
}

// MARK: - public Method

extension SYPhotoPicker {
    
    /// 顯示照片挑選器頁面
    /// - Parameters:
    ///   - currentVC: 當前頁面
    ///   - presentationStyle: UIModalPresentationStyle
    public func show(currentVC: UIViewController,
                     presentationStyle: UIModalPresentationStyle = .fullScreen) {
        
        SYPhotoPickerHelper.requestPermission(
            didAuthorized: {
                self.showPhotoPicker(currentVC: currentVC,
                                     modalPresentationStyle: presentationStyle)
            },
            didLimited: {
                self.showPhotoPicker(currentVC: currentVC,
                                     modalPresentationStyle: presentationStyle)
            },
            didDenied: {
                self.delegate?.photoPickerAuthorizedDenied?()
            })
    }
}
