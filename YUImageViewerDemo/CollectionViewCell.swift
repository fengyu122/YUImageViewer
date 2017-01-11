//
//  CollectionViewCell.swift
//  YUImageViewerDemo
//
//  Created by yu on 2017/1/11.
//  Copyright © 2017年 yu. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    let imageView=UIImageView()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(imageView)
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    func render(image:UIImage)
    {
        imageView.image=image
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame=contentView.bounds
    }
}
