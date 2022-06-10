//
//  SYBaseViewModel.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/4/22.
//

import Foundation

@objc protocol SYBaseViewModelDelegate {
}

class SYBaseViewModel: NSObject {
    
    weak var baseDelegate: SYBaseViewModelDelegate?
    
    deinit {
        print("Deinit: \(self)")
    }
}
