//
//  SYPhotoPickerVC.swift
//  SYPhotoPickerLibrary
//
//  Created by Ray on 2022/1/24.
//

import UIKit
import Photos

class SYPhotoPickerVC: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableContainerView: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    private var barLeftItem: UIBarButtonItem!
    private var barRightItem: UIBarButtonItem!
    
    weak var delegate: SYPhotoPickerDelegate?
    public var settings: SYPhotoPickerSetting?
    private var viewModel = SYPhotoPickerViewModel()
    private var albumTitleView: SYAlbumTitleView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupView()
        setupViewModel(viewModel: viewModel)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {

        return settings?.statusBarStyle ?? .lightContent
    }
    
    @IBAction func barLeftItemTouchUpInside(_ sender: Any) {
    
        viewModel.barLeftItemTouchUpInside()
    }
    
    @IBAction func barRightItemTouchUpInside(_ sender: Any) {
    
        viewModel.barRightItemTouchUpInside()
    }
}

// MARK: - Private Method

extension SYPhotoPickerVC {

    private func setupView() {
        
        setupNavigationBar()
        setupBarButton()
        setupCollectionView()
        setupTabelView()
        setupAlbumTitleView()
    }
    
    private func setupNavigationBar() {
        
        guard let settings = settings else { return }
        let foreground: UIColor = settings.barTextColor
        let background: UIColor = settings.barTintColor
        
        self.navigationController?.navigationBar.tintColor = foreground
        self.navigationController?.navigationBar.barTintColor = background
        self.navigationController?.navigationBar.isTranslucent = false
        
        guard #available(iOS 13.0, *) else { return }
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = background
        appearance.titleTextAttributes = [.foregroundColor: foreground]
        self.navigationController?.navigationBar.standardAppearance = appearance
        self.navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    private func setupBarButton() {
        
        guard let settings = settings else { return }
        barLeftItem = UIBarButtonItem()
        barLeftItem.target = self
        barLeftItem.action = #selector(barLeftItemTouchUpInside(_:))
        barLeftItem.title = settings.leftBarTitle
        barLeftItem.image = settings.leftBarImage
        
        barRightItem = UIBarButtonItem()
        barRightItem.target = self
        barRightItem.action = #selector(barRightItemTouchUpInside(_:))
        barRightItem.title = settings.rightBarTitle
        barRightItem.image = settings.rightBarImage
        barRightItem.isEnabled = false
        
        self.navigationItem.leftBarButtonItem = barLeftItem
        self.navigationItem.rightBarButtonItem = barRightItem
    }
    
    private func setupCollectionView() {
        
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let row = settings?.numberForRow ?? 4
        let spacing = CGFloat(1.5)
        let spacingTotal = CGFloat(row - 1) * spacing
        let width = (UIScreen.main.bounds.width - spacingTotal) / CGFloat(row)
        let itemSize = CGSize(width: width, height: width)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = spacing
        layout.minimumInteritemSpacing = spacing
        layout.itemSize = itemSize
        collectionView.collectionViewLayout = layout
        collectionView.register(UINib(nibName: "SYPhotoCell", bundle: .module), forCellWithReuseIdentifier: "SYPhotoCell")
        SYPhotoPickerHelper.shared.setupPhotoThumbnailSize(width: width)
    }
    
    private func setupTabelView() {
        
        tableViewHeight.constant = 0
        tableContainerView.layer.shadowColor = UIColor.black.cgColor
        tableContainerView.layer.shadowOpacity = 0.1
        tableContainerView.layer.shadowOffset = CGSize(width: 0, height: 4)
        tableContainerView.layer.shadowRadius = 20
        tableView.register(UINib(nibName: "SYAlbumCell", bundle: .module), forCellReuseIdentifier: "SYAlbumCell")
    }
    
    private func setupAlbumTitleView() {
        
        albumTitleView = SYAlbumTitleView()
        albumTitleView?.delegate = self
        albumTitleView?.updateView(settings: settings)
        navigationItem.titleView = albumTitleView
    }
}

// MARK: - AlbumTitleView Delegate

extension SYPhotoPickerVC: SYAlbumTitleViewDelegate {

    func albumButtonTouchUpInside() {
     
        viewModel.albumButtonTouchUpInside()
    }
}

// MARK: - UICollectionView DataSource

extension SYPhotoPickerVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return viewModel.getNumberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let data = viewModel.getItemData(indexPath: indexPath)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SYPhotoCell", for: indexPath)
        guard let cell = cell as? SYPhotoCell else { return cell }
        cell.setupData(data: data)
        return cell
    }
    
//    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
//      
//        let assets = viewModel.getPrefetchItemsData(indexPaths: indexPaths)
//        DispatchQueue.main.async {
//            SYPhotoPickerHelper.shared.startCacheImage(prefetchItemsAt: assets)
//        }
//    }
//    
//    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
//
//        let assets = viewModel.getPrefetchItemsData(indexPaths: indexPaths)
//        DispatchQueue.main.async {
//            SYPhotoPickerHelper.shared.startCacheImage(prefetchItemsAt: assets)
//        }
//    }
}

// MARK: - UICollectionView Delegate

extension SYPhotoPickerVC: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     
        viewModel.collectionViewDidSelect(indexPath: indexPath)
    }
}

// MARK: - UITableViewDataSource

extension SYPhotoPickerVC: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return viewModel.numberOfRowsInSection()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let data = viewModel.getCellData(indexPath: indexPath)
        let cell = tableView.dequeueReusableCell(withIdentifier: "SYAlbumCell", for: indexPath)
        guard let cell = cell as? SYAlbumCell else { return cell }
        cell.setupData(data: data)
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SYPhotoPickerVC: UITableViewDelegate {
    
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
    
    func setupViewModel(viewModel: SYBaseViewModel) {
     
        self.viewModel.delegate = self
        self.viewModel.initial(settings: settings)
    }
    
    func updateAlbumTitleView(text: String) {
        
        albumTitleView?.updateTitleLabel(text: text)
    }
    
    func updateAlbumTitleView(isRotateImage: Bool) {
        
        albumTitleView?.updateArrowImageView(isRotate: isRotateImage)
    }
    
    func updateBarRightItem(title: String, isEnable: Bool) {
        
        barRightItem.title = title
        barRightItem.isEnabled = isEnable
    }
    
    func updatePhotoCollectionViewCell(indexPath: IndexPath, isSelect: Bool, selectTitle: String) {
        
        guard let cell = collectionView.cellForItem(at: indexPath) as? SYPhotoCell else { return }
        cell.updateSelectStyle(isSelect: isSelect, title: selectTitle)
    }
    
    func updateAlbumTableView(isHidden: Bool) {
        
        let height = isHidden ? 0 : collectionView.frame.size.height
        tableViewHeight.constant = height
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.view.layoutIfNeeded()
        })
    }
    
    func collectionViewReloadItems(indexPath: [IndexPath]) {
    
        collectionView.reloadItems(at: indexPath)
    }
    
    func collectionViewReloadData() {
        
        collectionView.setContentOffset(.zero, animated: true)
        UIView.transition(with: collectionView,
                          duration: 0.35,
                          options: [.curveEaseInOut, .transitionCrossDissolve],
                          animations: { [weak self] in
            self?.collectionView.reloadData()
        })
    }
    
    func tableViewReloadData() {
        
        UIView.transition(with: tableView,
                          duration: 0.35,
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
    
    func photoPickerLimitReached() {
        delegate?.photoPickerLimitReached?()
    }
}
