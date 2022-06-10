//
//  SYPhotoCell.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/4/22.
//

import UIKit
import Photos

class SYPhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var opacityView: UIView!
    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var pickLabel: UILabel!
    @IBOutlet weak var pickLabelTopSpace: NSLayoutConstraint!
    @IBOutlet weak var pickLabelLeftSpace: NSLayoutConstraint!
    
    private var pickerSettings: SYPhotoPickerSetting?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.image = nil
    }
    
    func setupData(data: AnyObject) {
        
        guard let (data, settings) = data as? (AlbumData, SYPhotoPickerSetting?) else { return }
        setupPhotoPickerSetting(settings: settings)
        setupOpacityView(isSelect: data.isSelect)
        setupBorderView(isSelect: data.isSelect)
        setupPickLabel(isSelect: data.isSelect, title: data.selectTitle)
        fetchThumbnail(data: data)
    }
    
    func updateSelectStyle(isSelect: Bool, title: String) {
        
        UIView.animate(withDuration: 0.1, animations: { [weak self] in
            self?.setupOpacityView(isSelect: isSelect)
            self?.setupBorderView(isSelect: isSelect)
            self?.setupPickLabel(isSelect: isSelect, title: title)
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
        pickLabel.isHidden = true
        pickLabel.layer.cornerRadius = 10
    }
    
    private func fetchThumbnail(data: AlbumData) {
        
        let requestID = SYPhotoPickerHelper.shared.fetchThumbnail(
            form: data.assets, requestID: self.tag,
            completion: { [weak self] (image) in
                self?.setupPhotoImageView(image: image)
        })
        self.tag = Int(requestID ?? 0)
    }

    private func updateBorderView() {
     
        guard let setting = pickerSettings else { return }
        borderView.layer.borderWidth = setting.photoSelectBorderWidth
        borderView.layer.borderColor = setting.photoSelectColor.cgColor
    }
    
    private func updatePickLabel() {
        
        guard let setting = pickerSettings else { return }
        pickLabel.backgroundColor = setting.photoSelectColor
        
        let defaultSpace: CGFloat = 8
        let isTop = setting.photoPickLocation == .leftTop || setting.photoPickLocation == .rightTop
        let isLeft = setting.photoPickLocation == .leftTop || setting.photoPickLocation == .leftBottom
        let topSpace = isTop ? defaultSpace : self.frame.size.height - defaultSpace - pickLabel.frame.size.height
        let leftSpace = isLeft ? defaultSpace : self.frame.size.width - defaultSpace - pickLabel.frame.size.width
        pickLabelTopSpace.constant = topSpace
        pickLabelLeftSpace.constant = leftSpace
    }
}

// MARK: - Setup Data Private Methods

extension SYPhotoCell {
    
    private func setupPhotoPickerSetting(settings: SYPhotoPickerSetting?) {
     
        guard pickerSettings == nil else { return }
        pickerSettings = settings
        updateBorderView()
        updatePickLabel()
    }
    
    private func setupPhotoImageView(image: UIImage) {
        
        self.photoImageView.image = image
    }
    
    private func setupOpacityView(isSelect: Bool) {
        
        opacityView.isHidden = !isSelect
    }
    
    private func setupBorderView(isSelect: Bool) {
        
        borderView.isHidden = !isSelect
    }
    
    private func setupPickLabel(isSelect: Bool, title: String) {
        
        guard let setting = pickerSettings else { return }
        pickLabel.isHidden = !isSelect
        pickLabel.text = setting.photoSelectStyle == .string ? title : "✓"
    }
}
