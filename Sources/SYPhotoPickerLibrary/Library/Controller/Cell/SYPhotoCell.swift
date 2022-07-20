//
//  SYPhotoCell.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/4/22.
//

import UIKit
import Photos

/// 照片挑選器 Cell
class SYPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var pickLabel: UILabel!
    
    var values: (data: AlbumData?,
                 setting: SYPhotoPickerSetting) = (nil, SYPhotoPickerSetting()) {
        didSet { setData() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = nil
    }
    
    func updateSelectStyle(isSelect: Bool, title: String?) {
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.updataStyle(for: isSelect, title: title)
            self?.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, animations: { [weak self] in
                self?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }, completion: nil)
        })
    }
}

// MARK: - Private Methods

extension SYPhotoCell {
    
    private func setupView() {
        
        opacityView.isHidden = true
        borderView.isHidden = true
        
        pickLabel.text = nil
        pickLabel.isHidden = true
        pickLabel.layer.cornerRadius = 10
    }
    
    private func setData() {
        guard let data = values.data else { return }
        
        borderView.layer.borderWidth = values.setting.photoSelectBorderWidth
        borderView.layer.borderColor = values.setting.photoSelectColor.cgColor
        
        pickLabel.backgroundColor = values.setting.photoSelectColor
        
        updataStyle(for: data.isSelected, title: data.selectTitle)
        
        let requestID = SYPhotoPickerHelper.shared.fetchThumbnail(
            form: data.asset,
            requestID: tag,
            completion: { [weak self] (image) in
                self?.photoImageView.image = image
        })
        
        tag = Int(requestID)
    }
    
    /// 更改外觀樣式
    /// - Parameters:
    ///   - isSelected: 是否被選取
    ///   - title: 選取數字
    private func updataStyle(for isSelected: Bool, title: String?) {
        opacityView.isHidden = !isSelected
        borderView.isHidden = !isSelected
        pickLabel.isHidden = !isSelected
        
        pickLabel.text = values.setting.photoSelectStyle == .number ? title : "✓"
    }
}
