//
//  SYNavigationController.swift
//  CompanyLib
//
//  Created by Ray on 2022/6/16.
//

import UIKit

class SYNavigationController: UINavigationController {
    
    var settings: SYPhotoPickerSetting = SYPhotoPickerSetting() {
        didSet { updateStyle() }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        settings.statusBarStyle
    }
    
    /// 更新樣式
    private func updateStyle() {
        let foregroundColor: UIColor = settings.barTitleIconColor
        let backgroundColor: UIColor = settings.barTintColor
        
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = backgroundColor
            appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
            
            navigationBar.tintColor = foregroundColor
            navigationBar.standardAppearance = appearance
            navigationBar.scrollEdgeAppearance = appearance
            navigationBar.isTranslucent = false
        } else {
            navigationBar.tintColor = foregroundColor
            navigationBar.barTintColor = backgroundColor
            navigationBar.isTranslucent = false
        }
        
        // 更改狀態列顏色
        setNeedsStatusBarAppearanceUpdate()
    }

}
