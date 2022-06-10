//
//  SYAlbumTitleView.swift
//  SYPhotoPickerLibrary
//
//  Created by Kit on 2022/4/22.
//

import UIKit

@objc protocol SYAlbumTitleViewDelegate {
    
    @objc optional func albumButtonTouchUpInside()
}

class SYAlbumTitleView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var albumButton: UIButton!
    private var isAlbumOpen = false
    weak var delegate: SYAlbumTitleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupXib()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupXib()
    }
    
    @IBAction func albumButtonTouchUpInside(_ sender: Any) {
     
        delegate?.albumButtonTouchUpInside?()
        rotateArrowImageView()
    }
    
    func updateTitleLabel(text: String) {
        
        titleLabel.text = text
//        UIView.transition(with: titleLabel,
//                          duration: 0.15,
//                          options: .transitionCrossDissolve,
//                          animations: { [weak self] in
//            self?.titleLabel.text = text
//        }, completion: nil)
    }
    
    func updateArrowImageView(isRotate: Bool) {
        
        guard isRotate else { return }
        rotateArrowImageView()
    }
}

// MARK: - Private Method

extension SYAlbumTitleView {

    private func setupXib() {
        
        guard let xibView = loadXib() else { return }
        xibView.backgroundColor = .clear
        addSubview(xibView)
        frame = xibView.bounds
        xibView.translatesAutoresizingMaskIntoConstraints = false
        xibView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        xibView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        xibView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        xibView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        setupView()
    }
    
    private func loadXib() -> UIView? {

        guard let nibName = type(of: self).description().components(separatedBy: ".").last else { return nil }
        let nib = UINib(nibName: nibName, bundle: .module)
        guard let xibView = nib.instantiate(withOwner: self, options: nil).first as? UIView else { return nil }
        return xibView
    }
    
    private func setupView() {
        
        self.backgroundColor = .clear
        titleLabel.text = "SYPhotoPicker"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.clipsToBounds = true
        albumButton.setTitle("", for: .normal)
    }
    
    private func rotateArrowImageView() {
        
        let angle = isAlbumOpen ? 0 : (CGFloat.pi / 1)
        UIView.animate(withDuration: 0.35, animations: { [weak self] in
            self?.arrowImageView.transform = CGAffineTransform.identity.rotated(by: angle)
            self?.isAlbumOpen = !(self?.isAlbumOpen ?? false)
        })
    }
}

// MARK: - Interface Method

extension SYAlbumTitleView {

    public func updateView(settings: SYPhotoPickerSetting?) {
        
        guard let settings = settings else { return }
        self.titleLabel.textColor = settings.barTextColor
        self.arrowImageView.tintColor = settings.barTextColor
    }
}
