//
//  ViewController.swift
//  Combinestagram
//
//  Created by MTMAC16 on 04/09/18.
//  Copyright © 2018 bism. All rights reserved.
//

import UIKit
import RxSwift

class ViewController: UIViewController {
    lazy var image: UIImageView! = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .yellow
        imageView.layer.borderColor = UIColor.black.cgColor
        imageView.layer.borderWidth = 3
        imageView.layer.cornerRadius = 8
        
        return imageView
    }()
    
    lazy var btnClear: UIButton! = {
       let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = #colorLiteral(red: 0.5843137503, green: 0.8235294223, blue: 0.4196078479, alpha: 1)
        btn.setTitle("Clear", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.setTitleColor(.gray, for: UIControlState.disabled)
        btn.setTitleColor(.white, for: UIControlState.highlighted)
        btn.layer.cornerRadius = 40
        
        return btn
    }()
    
    lazy var btnSave: UIButton! = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.backgroundColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(.blue, for: .normal)
        btn.setTitleColor(.gray, for: UIControlState.disabled)
        btn.setTitleColor(.white, for: UIControlState.highlighted)
        btn.layer.cornerRadius = btn.frame.width / 2
        btn.layer.cornerRadius = 40
        
        return btn
    }()
    
    let disposeBag = DisposeBag()
    let images = Variable<[UIImage]>([])
    
    var imageCache = [Int]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        images.asObservable().subscribe(onNext: { pickedImages in
            self.image.image = UIImage.collage(images: pickedImages, size: self.image.frame.size)
            self.updateUI(images: pickedImages)
        }).disposed(by: disposeBag)
    }
    
    private func updateUI(images: [UIImage]) {
        btnClear.isEnabled = images.count > 0
    }
    
    private func setupUI() {
        self.title = "Combinstagram"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(ViewController.addItem))
        self.navigationController?.navigationBar.isTranslucent = false
        self.view.backgroundColor = .white
        
        configureSubview()
        configureConstraint()
        configureButtonAction()
    }
    
    private func configureSubview() {
        self.view.addSubview(image)
        self.view.addSubview(btnClear)
        self.view.addSubview(btnSave)
    }
    
    private func configureButtonAction() {
        btnClear.addTarget(self, action: #selector(ViewController.clear), for: .touchUpInside)
        btnSave.addTarget(self, action: #selector(ViewController.save), for: .touchUpInside)
    }
    
    private func configureConstraint() {
        NSLayoutConstraint.activate([
            //MARK: image constraint
            image.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 50),
            image.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 10),
            image.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10),
            image.heightAnchor.constraint(equalToConstant: 300),
            //MARK: btn clear constraint
            btnClear.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: -100),
            btnClear.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 50),
            btnClear.widthAnchor.constraint(equalToConstant: 80),
            btnClear.heightAnchor.constraint(equalToConstant: 80),
            //MARK: btn save constraint
            btnSave.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 100),
            btnSave.topAnchor.constraint(equalTo: image.bottomAnchor, constant: 50),
            btnSave.widthAnchor.constraint(equalToConstant: 80),
            btnSave.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    private func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
        imagePicker.sourceType = .savedPhotosAlbum
        
        self.navigationController?.present(imagePicker, animated: true, completion: nil)
    }
    
    private func updateNavigationBar() {
        let icon = image.image?.scaled(CGSize(width: 22, height: 22)).withRenderingMode(.alwaysOriginal)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: icon, style: UIBarButtonItemStyle.done, target: nil, action: nil)
    }
    
    //MARK: button action
    @objc func addItem() {
        let photoVC = PhotosViewController()
        
        let newPhoto = photoVC.selectedPhoto.share()
        
        newPhoto.filter({ (image) -> Bool in
            image.size.width > image.size.height
        }).filter({ (image) -> Bool in
            let length = UIImagePNGRepresentation(image)?.count ?? 0
            
            guard self.imageCache.contains(length) == false else {
                return false
            }
            self.imageCache.append(length)
            return true
        }).subscribe(onNext: { (image) in
            self.images.value.append(image)
        }).disposed(by: disposeBag)
        
        newPhoto
            .ignoreElements().subscribe(onCompleted: {
                self.updateNavigationBar()
            }).disposed(by: disposeBag)
        
        self.navigationController?.pushViewController(photoVC, animated: true)
    }
    
    @objc func clear() {
        images.value.removeAll()
        imageCache.removeAll()
    }
    
    @objc func save() {
        self.navigationController?.pushViewController(PhotosViewController(), animated: true)
    }
}

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            images.value.append(pickedImage)
            picker.dismiss(animated: true, completion: nil)
        }
    }
}
