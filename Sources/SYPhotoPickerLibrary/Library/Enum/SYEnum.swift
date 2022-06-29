//
//  PublicEnum.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/23.
//

import UIKit

// MARK: - SYPhotoPickerType

/// 照片挑選器樣式
public enum SYPhotoPickerType {
    
    /// 預設
    case `default`
    
    /// TopAgent 3
    case ta
    
    /// Sinyi IM
    case im
    
}

// MARK: - SYPhotoSelectSytle

/// 照片選取時，右上角顯示風格
public enum SYPhotoSelectSytle {
    
    /// 數字
    case number
    
    /// 打勾
    case checkbox
}

// MARK: - SYColor

public enum SYColor {
    
    /// hex: 0ba360, rgb(11, 163, 96)
    public static let green = UIColor(red: 11 / 255, green: 163 / 255, blue: 96 / 255, alpha: 1.0)
    
    /// hex: 008800, rgb(0, 136, 0)
    public static let greenDeep = UIColor(red: 0 / 255, green: 136 / 255, blue: 0 / 255, alpha: 1.0)
    
    /// hex: 4a4a4a, rgb(74, 74, 74)
    public static let black = UIColor(red: 74 / 255, green: 74 / 255, blue: 74 / 255, alpha: 1.0)
    
    /// hex: 5a5a5a, rgb(90, 90, 90)
    public static let blackLight = UIColor(red: 90 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
    
    /// hex: f2f2f2, rgb(242, 242, 242)
    public static let gray = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1.0)
    
    /// hex: e6e6e6, rgb(230, 230, 230)
    public static let background = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1.0)
}

// MARK: - SYImage

public enum SYImage: String {
    
    /// 向下箭頭(灰色)
    case downArrow = "ic-arrow-down-gray"
    
    /// 關閉(白色)
    case close = "ic-close-white"
    
    /// 圖示
    public var image: UIImage? {
        return UIImage(named: rawValue, in: .module, compatibleWith: nil)
    }
}
