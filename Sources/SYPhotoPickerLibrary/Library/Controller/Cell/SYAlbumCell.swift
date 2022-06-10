//
//  SYAlbumCell.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/4/22.
//

import UIKit

class SYAlbumCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    private var pickerSettings: SYPhotoPickerSetting?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setupData(data: AnyObject) {
        
        guard let (data, settings) = data as? (AlbumFolder, SYPhotoPickerSetting?) else { return }
        setupPhotoPickerSetting(settings: settings)
        setupTitleLabel(data: data)
        setupInfoLable(data: data)
        fetchThumbnail(data: data)
    }
}

// MARK: - Private Methods

extension SYAlbumCell {
    
    private func setupView() {
        
        titleLabel.font = .boldSystemFont(ofSize: 17)
        infoLabel.font = .systemFont(ofSize: 13)
        
        titleLabel.textColor = .black
        infoLabel.textColor = SYColor.mainBlackLight
    }
    
    private func updateTitleLabel() {
        
        guard let setting = pickerSettings else { return }
        titleLabel.textColor = setting.albumTitleColor
    }
    
    private func fetchThumbnail(data: AlbumFolder) {
        
        guard let assest = data.assets.firstObject else { return }
        let requestID = SYPhotoPickerHelper.shared.fetchThumbnail(
            form: assest, requestID: self.tag,
            completion: { [weak self] (image) in
                self?.setupPhotoImageView(image: image)
        })
        self.tag = Int(requestID ?? 0)
    }
}

// MARK: - Setup Data Private Methods

extension SYAlbumCell {

    private func setupPhotoPickerSetting(settings: SYPhotoPickerSetting?) {
     
        guard pickerSettings == nil else { return }
        pickerSettings = settings
        updateTitleLabel()
    }
    
    private func setupTitleLabel(data: AlbumFolder) {
        
        titleLabel.text = data.title
    }
    
    private func setupInfoLable(data: AlbumFolder) {
        
        infoLabel.text = "\(data.count)"
    }
    
    private func setupPhotoImageView(image: UIImage) {
        
        self.photoImageView.image = image
    }
}
