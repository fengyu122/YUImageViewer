//
//  ViewController.swift
//  YUImageViewerDemo
//
//  Created by yu on 2017/1/8.
//  Copyright © 2017年 yu. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YUImageViewerViewControllerProtocol {
    func imageViewerViewController(_ viewController: YUImageViewerViewController, onLongPressAt index: Int, image: UIImage?) {
         print("长按图片啦:\(index)")
    }
    func imageViewerViewController(_ viewController: YUImageViewerViewController, downloadImageAt index: Int, imageView: UIImageView, complete: @escaping (Bool) -> ()) {
//           imageView.sd_setImage(with: models[index].url, placeholderImage: nil, options: []) { (image, error, type, url) in
//            if let _=error
//            {
//                complete(false)
//            }else
//            {
//                complete(true)
//            }
//        }
    
    }
    var models=[YUImageViewerModel]()
    override func viewDidLoad() {
        super.viewDidLoad()
        let layout=UICollectionViewFlowLayout()
        layout.scrollDirection=UICollectionViewScrollDirection.vertical
        let collectionView=UICollectionView.init(frame: view.bounds, collectionViewLayout: layout)
        collectionView.register(CollectionViewCell.self, forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.delegate=self
        collectionView.dataSource=self
        collectionView.backgroundColor=UIColor.white
        view.addSubview(collectionView)
        initModels()

       
    }
    private func initModels()
    {
        let model1=YUImageViewerModel()
        model1.placeholder=UIImage.init(named: "pic1")
       // model1.url=URL.init(string: "http://uploads.yjbys.com/allimg/201612/42-16120Q60624.jpg")
         model1.url=URL.init(string: "https://ss0.bdstatic.com/5aV1bjqh_Q23odCf/static/superman/img/logo/bd_logo1_31bdc765.png")
        
        let model2=YUImageViewerModel()
        model2.placeholder=UIImage.init(named: "pic2")
        model2.url=URL.init(string: "http://tupian.qqjay.com/u/2016/1024/1_174548_3.jpg")
        
        let model3=YUImageViewerModel()
        model3.placeholder=UIImage.init(named: "pic3")
        model3.url=URL.init(string: "http://img.sc115.com/uploads/sc/jpgs/1203apic2321_sc115.com.jpg")
       
        
        models+=[model1,model2,model3]

    }
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.render(image: models[indexPath.row].placeholder!)
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize.init(width: 80, height: 80)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 40, left: 20, bottom: 20, right: 20)
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cells=collectionView.visibleCells as! [CollectionViewCell]
        for model in models
        {
            model.frame=nil
        }
        for cell in cells
        {
            let newFrame=view.convert(cell.imageView.frame, from: cell.contentView)
            if let index=collectionView.indexPath(for: cell)?.item
            {
                models[index].frame=newFrame
            }
        }
        let vc=YUImageViewerViewController.init(models: models, currentSelect: indexPath.item, delegate: self)
        present(vc, animated: true, completion: nil)
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  

}

