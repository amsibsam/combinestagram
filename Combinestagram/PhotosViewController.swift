//
//  PhotosViewController.swift
//  Combinestagram
//
//  Created by MTMAC16 on 04/09/18.
//  Copyright © 2018 bism. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa
import Photos

class PhotosViewController: UIViewController {
    private lazy var collectionView: UICollectionView! = {
       let collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: UICollectionViewFlowLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        return collectionView
    }()
    
    private var photos: PHFetchResult<PHAsset> = PhotosViewController.loadPhotos()
    
    static func loadPhotos() -> PHFetchResult<PHAsset> {
        let allPhotoOption = PHFetchOptions()
        allPhotoOption.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        return PHAsset.fetchAssets(with: allPhotoOption)
    }
    
    private let selectedPhotosSubject = PublishSubject<UIImage>()
    
    var selectedPhoto: Observable<UIImage> {
        return selectedPhotosSubject
    }
    
    private lazy var imageManager = PHCachingImageManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureSubview()
        configureConstraint()
    }
    
    private func setupUI() {
        self.view.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(PhotoCell.self, forCellWithReuseIdentifier: "photosCell")
    }
    
    private func configureSubview() {
        self.view.addSubview(collectionView)
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            //MARK: Collection view constraints
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -8),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 8)
        ])
    }
}

extension PhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("photos count \(photos.count)")
        return photos.count
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 100, height: 100)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let asset = photos.object(at: indexPath.item)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photosCell", for: indexPath) as! PhotoCell
        
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFill, options: nil) { (imagePH, info) in
            if let image = imagePH {
                cell.image.image = image
            }
        }
        
        return cell
    }
}

extension PhotosViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = photos.object(at: indexPath.item)
        
        imageManager.requestImage(for: asset, targetSize: view.frame.size, contentMode: .aspectFit, options: nil) { (image, info) in
            if let pickedImage = image {
                self.selectedPhotosSubject.onNext(pickedImage)
                self.selectedPhotosSubject.onCompleted()
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
}
