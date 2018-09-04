//
//  PhotoCell.swift
//  Combinestagram
//
//  Created by MTMAC16 on 04/09/18.
//  Copyright © 2018 bism. All rights reserved.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    var image: UIImageView = {
       let imageView = UIImageView()
        imageView.contentMode = .scaleToFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .green
        return imageView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .blue
        addSubview(image)
        
        NSLayoutConstraint.activate([
            image.widthAnchor.constraint(equalToConstant: 100),
            image.heightAnchor.constraint(equalToConstant: 100),
            image.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 0),
            image.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0),
        ])
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("error")
    }
}
