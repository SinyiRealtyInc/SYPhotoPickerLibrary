//
//  SYAlbumCell.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/4/22.
//

import UIKit

/// 相簿挑選清單 Cell
class SYAlbumCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var countLabel: UILabel!
    
    /// 資料集(AlbumFolder, SYPhotoPickerSetting)
    var values: (folder: AlbumFolder?,
                 setting: SYPhotoPickerSetting) = (nil, SYPhotoPickerSetting()) {
        didSet { setData() }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

// MARK: - Private Methods

extension SYAlbumCell {
    
    private func setupView() {
        
        titleLabel.font = .boldSystemFont(ofSize: 17)
        countLabel.font = .systemFont(ofSize: 13)
        
        titleLabel.textColor = .black
        countLabel.textColor = SYColor.blackLight
    }
    
    private func setData() {
        
        titleLabel.text = values.folder?.title
        titleLabel.textColor = values.setting.photoSelectColor
        
        countLabel.text = "\(values.folder?.count ?? 0)"
        
        guard let assest = values.folder?.assets.firstObject else { return }
        
        let requestID = SYPhotoPickerHelper.shared.fetchThumbnail(
            form: assest,
            requestID: tag,
            completion: { [weak self] (image) in
                self?.photoImageView.image = image
        })
        
        tag = Int(requestID ?? 0)
    }
}
