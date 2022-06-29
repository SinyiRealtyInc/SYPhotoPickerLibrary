//
//  SYPhotoPickerSetting.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/23.
//

import UIKit
import Photos

// MARK: - PhotoPickerSetting

public protocol PhotoPickerSetting {
    
    /// 狀態列顏色
    var statusBarStyle: UIStatusBarStyle { get set }
    
    /// NavigationBar 被景色
    var barTintColor: UIColor { get set }
    
    /// NavigationBar 標題/圖示顏色
    var barTitleIconColor: UIColor { get set }
    
    /// NavigationBar 左邊標題
    var leftBarTitle: String? { get set }
    
    /// NavigationBar 右邊標題
    var rightBarTitle: String? { get set }
    
    /// NavigationBar 左邊圖示
    var leftBarImage: UIImage? { get set }
    
    /// NavigationBar 右邊圖示
    var rightBarImage: UIImage? { get set }
    
    /// 照片張數選取上限
    var limitCount: Int { get set }
    
    /// 每行幾個Item
    var numberForRow: Int { get set }
    
    /// 照片選取UI樣式
    var photoSelectStyle: SYPhotoSelectSytle { get set }
    
    /// 照片選取邊框寬度
    var photoSelectBorderWidth: CGFloat { get set }
    
    /// 照片選取顏色
    var photoSelectColor: UIColor { get set }
    
    /// 已選取的照片
    var selectedPhotos: [PHAsset] { get set }
}

public struct SYPhotoPickerSetting: PhotoPickerSetting {
    
    public var statusBarStyle: UIStatusBarStyle = .lightContent
    public var barTintColor: UIColor = .systemOrange
    public var barTitleIconColor: UIColor = .white
    public var leftBarTitle: String? = nil
    public var rightBarTitle: String? = "確認"
    public var leftBarImage: UIImage? = SYImage.close.image
    public var rightBarImage: UIImage? = nil
    public var limitCount: Int = 10
    public var numberForRow: Int = 4
    public var photoSelectStyle: SYPhotoSelectSytle = .number
    public var photoSelectBorderWidth: CGFloat = 2
    public var photoSelectColor: UIColor = .systemOrange
    public var selectedPhotos: [PHAsset] = []
}
