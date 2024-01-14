//
//  SYPhotoPickerVC.swift
//  SYPhotoPickerLibrary
//
//  Created by Ray on 2022/1/24.
//

import UIKit
import Photos
import PhotosUI

class SYPhotoPickerVC: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    
    /// NavigationBar Title Button
    private lazy var barTitleButton: UIButton = {
        let button = UIButton(type: .custom)
        
        // 設定寬度其他不用，因系統會自動設定
        button.frame = CGRect(x: 0.0, y: 0.0, width: 200.0, height: 0.0)
        
        button.setTitleColor(settings.barTitleIconColor, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 17)
        button.setImage(UIImage(named: "ic-arrow-down", in: .module, compatibleWith: nil),
                        for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -8.0, bottom: 0.0, right: 0.0)
        button.semanticContentAttribute = .forceRightToLeft
        button.addTarget(self,
                         action: #selector(showPhotoAlbums(_:)),
                         for: .touchUpInside)
        
        return button
    }()
    
    private lazy var barLeftItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.target = self
        barButton.action = #selector(barButtonTap(_:))
        barButton.title = settings.leftBarTitle
        barButton.image = settings.leftBarImage
        
        return barButton
    }()
    
    private lazy var barRightItem: UIBarButtonItem = {
        let barButton = UIBarButtonItem()
        barButton.target = self
        barButton.action = #selector(barButtonTap(_:))
        barButton.title = settings.rightBarTitle
        barButton.image = settings.rightBarImage
        barButton.isEnabled = settings.selectedPhotos.isEmpty == false
        
        return barButton
    }()
    
    /// 動畫時長, value = 0.32
    private let transitionDuration: TimeInterval = 0.32
    
    private var viewModel: SYPhotoPickerViewModel = SYPhotoPickerViewModel()
    
    var settings: SYPhotoPickerSetting = SYPhotoPickerSetting()
    
    weak var delegate: SYPhotoPickerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        setupCollectionView()
        setupTabelView()
    }
}

// MARK: - Private Method

extension SYPhotoPickerVC {
    
    private func setup() {
        navigationItem.leftBarButtonItem = barLeftItem
        navigationItem.rightBarButtonItem = barRightItem
        navigationItem.titleView = barTitleButton
        
        view.backgroundColor = .white
        
        viewModel.delegate = self
        viewModel.initial(settings: settings)
    }
    
    private func setupCollectionView() {
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout
        else {
            return
        }
        
        let row = settings.numberForRow
        let spacing = CGFloat(1.5)
        let spacingTotal = CGFloat(row - 1) * spacing
        let width = (UIScreen.main.bounds.width - spacingTotal) / CGFloat(row)
        let itemSize = CGSize(width: width, height: width)
        
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.itemSize = itemSize
        
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "SYPhotoCell", bundle: .module),
                                forCellWithReuseIdentifier: "SYPhotoCell")
        
        SYPhotoPickerHelper.shared.setupPhotoThumbnailSize(value: width)
    }
    
    private func setupTabelView() {
        
        tableViewHeight.constant = 0
        
        tableContainerView.layer.shadowColor = UIColor.black.cgColor
        tableContainerView.layer.shadowOpacity = 0.1
        tableContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        tableContainerView.layer.shadowRadius = 20
        
        tableView.register(UINib(nibName: "SYAlbumCell", bundle: .module),
                           forCellReuseIdentifier: "SYAlbumCell")
    }
}

// MARK: - UICollectionViewDataSource & UICollectionViewDelegate

extension SYPhotoPickerVC: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.getPhotoCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SYPhotoCell",
                                                            for: indexPath) as? SYPhotoCell
        else {
            return UICollectionViewCell()
        }
        
        cell.values = (viewModel.getPhoto(for: indexPath), settings)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        viewModel.collectionViewDidSelect(indexPath: indexPath)
    }
    
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
    
        let assets = viewModel.getPrefetchItemsData(indexPaths: indexPaths)
        
        DispatchQueue.main.async {
            SYPhotoPickerHelper.shared.startCacheImage(prefetchItemsAt: assets)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
    
        let assets = viewModel.getPrefetchItemsData(indexPaths: indexPaths)
        
        DispatchQueue.main.async {
            SYPhotoPickerHelper.shared.stopCacheImage(cancelPrefetchingForItemsAt: assets)
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension SYPhotoPickerVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.getAlbumFolderCount()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "SYAlbumCell",
                                                       for: indexPath) as? SYAlbumCell
        else {
            return UITableViewCell()
        }
        
        cell.values = (viewModel.getFolder(for: indexPath), settings)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        viewModel.tableViewDidSelectRowAt(indexPath: indexPath)
    }
}

// MARK: - SYPhotoPickerDelegate

extension SYPhotoPickerVC: SYPhotoPickerViewModelDelegate {
    
    func updateNavigationTitle(for text: String?) {
        barTitleButton.setTitle(text, for: .normal)
    }
    
    func updateNavigationArrow(for open: Bool) {
        let rotation =  CGAffineTransform(rotationAngle: open ? .pi * 2 : .pi)
        
        UIView.animate(withDuration: 0.32)
        { [weak self] in
            self?.barTitleButton.imageView?.transform = rotation
        }
    }
    
    func updateBarRightItem(title: String, isEnable: Bool) {
        barRightItem.title = title
        barRightItem.isEnabled = isEnable
    }
    
    func showingAlbumList(isHidden: Bool) {
        
        let height = isHidden ? 0 : collectionView.frame.size.height
        tableViewHeight.constant = height
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    func updatePhotoCollectionViewCell(indexPath: IndexPath, isSelect: Bool, selectTitle: String) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SYPhotoCell else { return }
        
        cell.updateSelectStyle(isSelect: isSelect, title: selectTitle)
    }
    
    func collectionViewReloadItems(indexPath: [IndexPath]) {
        
        collectionView.reloadItems(at: indexPath)
    }
    
    func collectionViewReloadData() {
        
        collectionView.setContentOffset(.zero, animated: false)
        
        UIView.transition(
            with: collectionView,
            duration: transitionDuration,
            options: [.curveEaseInOut, .transitionCrossDissolve],
            animations: { [weak self] in
                self?.collectionView.reloadData()
            })
    }
    
    func tableViewReloadData() {
        
        UIView.transition(
            with: tableView,
            duration: transitionDuration,
            options: [.curveEaseInOut, .transitionCrossDissolve],
            animations: { [weak self] in
                self?.tableView.reloadData()
            })
    }
    
    func photoPickerDidSelect(asset: PHAsset) {
        
        delegate?.photoPickerDidSelect?(asset: asset)
    }
    
    func photoPickerDidDeselect(asset: PHAsset) {
        
        delegate?.photoPickerDidDeselect?(asset: asset)
    }
    
    func photoPickerConfirm(assets: [PHAsset]) {
        
        delegate?.photoPickerConfirm?(assets: assets)
        self.dismiss(animated: true, completion: nil)
    }
    
    func photoPickerDismiss() {
        
        delegate?.photoPickerDismiss?()
        self.dismiss(animated: true, completion: nil)
    }
    
    func photoPickerDidLimit() {
        
        delegate?.photoPickerDidLimit?()
    }
}

// MARK: - Action

extension SYPhotoPickerVC {
    
    @objc private func barButtonTap(_ barButton: UIBarButtonItem) {
        switch barButton {
        case barLeftItem:
            viewModel.pickerDismiss()
        case barRightItem:
            viewModel.pickerConfirm()
        default:
            break
        }
    }
    
    /// 開啟相簿選擇清單
    @objc private func showPhotoAlbums(_ button: UIButton) {
        guard viewModel.getAlbumFolderCount() > 0 else {
            if #available(iOS 15, *) {
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self) { [weak self] values in
                    self?.viewModel.loadAlbums()
                }
            } else if #available(iOS 14, *) {
                // 僅第一次才監聽相簿更動
                PHPhotoLibrary.shared().register(self)
                PHPhotoLibrary.shared().presentLimitedLibraryPicker(from: self)
            }
            
            return
        }
        
        viewModel.showPhotoAlbums()
    }
}

// MARK: - PHPhotoLibraryChangeObserver

extension SYPhotoPickerVC: PHPhotoLibraryChangeObserver {
    
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        DispatchQueue.main.async {
            self.viewModel.loadAlbums()
        }
        
        PHPhotoLibrary.shared().unregisterChangeObserver(self)
    }
}
