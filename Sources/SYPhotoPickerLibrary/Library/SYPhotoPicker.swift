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
    
    @objc optional func photoPickerDidSelect(asset: PHAsset)
    @objc optional func photoPickerDidDeselect(asset: PHAsset)
    @objc optional func photoPickerConfirm(assets: [PHAsset])
    @objc optional func photoPickerDismiss()
    @objc optional func photoPickerLimitReached()
    @objc optional func photoPickerAuthorizedDenied()
}

public class SYPhotoPicker {
    
    public weak var delegate: SYPhotoPickerDelegate?
    public var settings: SYPhotoPickerSetting = SYPhotoPickerSetting()
    private var type: SYPhotoPickerType = .ta
}

extension SYPhotoPicker {
    
    public convenience init(type: SYPhotoPickerType) {
        
        self.init()
        self.type =  type
        self.setupPhotoPickerSetting(type: type)
    }
}

// MARK: - Private Method

extension SYPhotoPicker {
    
    private func setupPhotoPickerSetting(type: SYPhotoPickerType) {
        
        if type == .ta { setupTaSetting() }
        if type == .im { setupImSetting() }
    }
    
    private func setupTaSetting() {
        
        settings.statusBarStyle = .lightContent
        settings.barTintColor = SYColor.mainGreen
        settings.barTextColor = .white
        settings.leftBarTitle = ""
        settings.rightBarTitle = "確認"
        settings.leftBarImage = SYImage.close.image
        settings.rightBarImage = nil
        settings.limitCount = 21
        settings.numberForRow = 4
        settings.photoSelectStyle = .string
        settings.photoSelectBorderWidth = 2
        settings.photoSelectColor = SYColor.mainGreen
        settings.photoPickLocation = .rightTop
        settings.albumTitleColor = SYColor.mainGreen
    }
    
    private func setupImSetting() {
        
        settings.statusBarStyle = .default
        settings.barTintColor = .white
        settings.barTextColor = SYColor.mainBlack
        settings.leftBarTitle = ""
        settings.rightBarTitle = "傳送"
        settings.leftBarImage = SYImage.close.image
        settings.rightBarImage = nil
        settings.limitCount = 10
        settings.numberForRow = 4
        settings.photoSelectStyle = .symbol
        settings.photoSelectBorderWidth = 0
        settings.photoSelectColor = SYColor.mainGreenDeep
        settings.photoPickLocation = .rightBottom
        settings.albumTitleColor = .black
    }
    
    private func showPhotoPicker(currentVC: UIViewController, modalPresentationStyle: UIModalPresentationStyle) {
        
        DispatchQueue.main.async {
            let photoPickerVC = SYPhotoPickerVC(nibName: "SYPhotoPickerVC", bundle: .module)
            photoPickerVC.settings = self.settings
            photoPickerVC.delegate = self.delegate
            
            let navigationController = UINavigationController(rootViewController: photoPickerVC)
            navigationController.modalPresentationStyle = modalPresentationStyle
            currentVC.present(navigationController, animated: true, completion: nil)
        }
    }
}

// MARK: - public Method

extension SYPhotoPicker {
    
    public func show(currentVC: UIViewController, modalPresentationStyle: UIModalPresentationStyle = .fullScreen) {
        
        SYPhotoPickerHelper.requestPermission(
            didAuthorized: {
                self.showPhotoPicker(currentVC: currentVC, modalPresentationStyle: modalPresentationStyle)
            },
            didLimited: {
                self.showPhotoPicker(currentVC: currentVC, modalPresentationStyle: modalPresentationStyle)
            },
            didDenied: {
                self.delegate?.photoPickerAuthorizedDenied?()
            })
    }
}
