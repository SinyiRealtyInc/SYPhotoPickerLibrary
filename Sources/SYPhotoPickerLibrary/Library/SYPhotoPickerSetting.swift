//
//  SYPhotoPickerSetting.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/23.
//

import Foundation
import UIKit
import Photos

// MARK: - PhotoPickerSetting
public protocol PhotoPickerSetting {

    var statusBarStyle: UIStatusBarStyle { get set }
    var barTintColor: UIColor { get set }
    var barTextColor: UIColor { get set }
    var leftBarTitle: String { get set }
    var rightBarTitle: String { get set }
    var leftBarImage: UIImage? { get set }
    var rightBarImage: UIImage? { get set }
    var limitCount: Int { get set }
    var numberForRow: Int { get set }
    var photoSelectStyle: SYPhotoSelectSytle { get set }
    var photoSelectBorderWidth: CGFloat { get set }
    var photoSelectColor: UIColor { get set }
    var selectedPhotos: [PHAsset]? { get set }
}

public struct SYPhotoPickerSetting: PhotoPickerSetting {
    
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    public var barTintColor: UIColor = SYColor.mainBlue
    public var barTextColor: UIColor = .white
    public var leftBarTitle: String = ""
    public var rightBarTitle: String = ""
    public var leftBarImage: UIImage? = SYImage.close.image
    public var rightBarImage: UIImage? = SYImage.sad.image
    public var limitCount: Int = 10
    public var numberForRow: Int = 4
    public var photoSelectStyle: SYPhotoSelectSytle = .string
    public var photoSelectBorderWidth: CGFloat = 2
    public var photoSelectColor: UIColor = SYColor.mainBlue
    public var photoPickLocation: SYPhotoPickLocation = .leftTop
    public var albumTitleColor: UIColor = SYColor.mainBlue
    public var selectedPhotos: [PHAsset]? = nil
}
