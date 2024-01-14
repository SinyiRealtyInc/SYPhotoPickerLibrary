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
        
        // 目前無支援深色模式，直接強制亮色模式
        overrideUserInterfaceStyle = .dark
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        settings.statusBarStyle
    }
    
    /// 更新樣式
    private func updateStyle() {
        let foregroundColor: UIColor = settings.barTitleIconColor
        let backgroundColor: UIColor = settings.barTintColor
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = backgroundColor
        appearance.titleTextAttributes = [.foregroundColor: foregroundColor]
        
        navigationBar.tintColor = foregroundColor
        navigationBar.standardAppearance = appearance
        navigationBar.scrollEdgeAppearance = appearance
        navigationBar.isTranslucent = false
        
        // 更改狀態列顏色
        setNeedsStatusBarAppearanceUpdate()
    }

}
