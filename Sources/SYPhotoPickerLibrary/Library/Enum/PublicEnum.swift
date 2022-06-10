//
//  PublicEnum.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/3/23.
//

import Foundation
import UIKit

// MARK: - SYPhotoPickerType
public enum SYPhotoPickerType {
    
    case ta
    case im
    case custom
}

// MARK: - SYPhotoSelectSytle
public enum SYPhotoSelectSytle {
    
    case string
    case symbol
}

// MARK: - SYPhotoPickLocation
public enum SYPhotoPickLocation {
   
    case leftTop
    case rightTop
    case leftBottom
    case rightBottom
}

// MARK: - SYColor
public enum SYColor {
    
    /// hex: 0x8BC34A
    public static let mainGreen = UIColor(red: 139 / 255, green: 195 / 255, blue: 74 / 255, alpha: 1.0)
    
    /// hex: 008800
    public static let mainGreenDeep = UIColor(red: 0 / 255, green: 136 / 255, blue: 0 / 255, alpha: 1.0)
    
    /// hex: 464646
    public static let mainBlack = UIColor(red: 70 / 255, green: 70 / 255, blue: 70 / 255, alpha: 1.0)
    
    /// hex: 0x5A5A5A
    public static let mainBlackLight = UIColor(red: 90 / 255, green: 90 / 255, blue: 90 / 255, alpha: 1.0)
    
    /// hex: 0xF2F2F2
    public static let mainGray = UIColor(red: 242 / 255, green: 242 / 255, blue: 242 / 255, alpha: 1.0)
    
    /// hex: e6e6e6
    public static let mainBackground = UIColor(red: 230 / 255, green: 230 / 255, blue: 230 / 255, alpha: 1.0)
    
    /// hex: 0066cc
    public static let mainBlue = UIColor(red: 0 / 255, green: 102 / 255, blue: 204 / 255, alpha: 1.0)
}

// MARK: - SYImage
public enum SYImage: String {

    case downArrow = "ic-arrow-down-white"
    case close = "ic-close-white"
    case menu = "ic-menu-white"
    case sad = "ic-sad-white"
    
    public var image: UIImage {
        return UIImage(named: rawValue, in: .module, compatibleWith: nil) ?? UIImage()
    }
}
