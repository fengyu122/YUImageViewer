    //
    //  ViewController.swift
    //  YUImageViewerDemo
    //
    //  Created by yu on 2017/1/8.
    //  Copyright © 2017年 yu. All rights reserved.
    //

    import UIKit

    class ViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,YUImageViewerViewControllerDelegate {

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
            collectionView.translatesAutoresizingMaskIntoConstraints=false
            view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .left, relatedBy: .equal, toItem: view, attribute: .left, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .right, relatedBy: .equal, toItem: view, attribute: .right, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint.init(item: collectionView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0))
            initModels()

           
        }
        private func initModels()
        {
            let model1=YUImageViewerModel()
            model1.placeholder=UIImage.init(named: "pic1") //可选。nil值将以淡入淡出的方式显示
            model1.url=URL.init(string: "http://uploads.yjbys.com/allimg/201612/42-16120Q60624.jpg")
            //model1.frame=view.convert(cell.imageView.frame, from: cell.contentView) //frame是相对于当前ViewController的！！！。请使用covert函数转换。nil值将以淡入淡出的效果显示
            
            let model2=YUImageViewerModel()
            model2.placeholder=UIImage.init(named: "pic2")
            model2.url=URL.init(string: "http://tupian.qqjay.com/u/2016/1024/1_174548_3.jpg")
            
            let model3=YUImageViewerModel()
            model3.placeholder=UIImage.init(named: "pic3")
            model3.url=URL.init(string: "http://img.sc115.com/uploads/sc/jpgs/1203apic2321_sc115.com.jpg")
           
            let model4=YUImageViewerModel()
            model4.placeholder=UIImage.init(named: "pic4")
            model4.url=URL.init(string: "http://pic14.nipic.com/20110516/3101644_221206899369_2.jpg")
            
            let model5=YUImageViewerModel()
            model5.placeholder=UIImage.init(named: "pic5")
            model5.url=URL.init(string: "https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1484154746182&di=d5cecfe2eb223bc073f58cb509224142&imgtype=0&src=http%3A%2F%2Fimg5.duitang.com%2Fuploads%2Fitem%2F201209%2F01%2F20120901013416_VRzkB.thumb.224_0.jpeg")
            
            let model6=YUImageViewerModel()
            model6.placeholder=UIImage.init(named: "pic6")
            model6.url=URL.init(string: "http://img3.utuku.china.com/640x0/news/20170111/3bed5942-803e-4b0d-ad34-a90f022d7970.jpg")
            
            let model7=YUImageViewerModel()
            model7.placeholder=UIImage.init(named: "pic7")
            model7.url=URL.init(string: "http://images.photoshopcn.com/h000/h91/img200801101151310.jpg")
            
            models+=[model1,model2,model3,model4,model5,model6,model7]

        }
        //MARK: -UICollectionViewDelegate
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

        
        
        // MARK: - YUImageViewerViewControllerDelegate
        //下载图片的代理。必须实现。你可以选择你项目中的图片下载框架。下载完成后执行 complete() 这个closure。传true表示下载成功 传false表示下载失败
        func imageViewerViewController(_ viewController: YUImageViewerViewController, downloadImageAt index: Int, imageView: UIImageView, model: YUImageViewerModel, complete: @escaping DownloadCompleteBlock) {
            //请使用项目中的图片下载框架进行下载。这里只是简单的实例
            DispatchQueue.global().async {
                
                do{
                    let data=try Data.init(contentsOf: model.url!)
                    DispatchQueue.main.async(execute: {
                        imageView.image=UIImage.init(data: data)
                        complete(true) //下载成功调用
                    })
                }
                catch
                {
                    complete(false)//下载失败调用
                }
                
            }
            
            
            // 使用SDWebImage下载代码实例
            /*
             imageView.sd_setImage(with: models[index].url, placeholderImage: models[index].placeholder, options: []) { (image, error, type, url) in
             if let _=error
             {
             complete(false)
             //若下载失败可以在这里添加提示的代码。框架并不会提示
             }else
             {
             complete(true)
             }
             }
             */
            
        }
       
         //在这里。你可以对长按的图片进行操作。比如保存图片或者分享
        func imageViewerViewController(_ viewController: YUImageViewerViewController, onLongPressAt index: Int, image: UIImage?, model: YUImageViewerModel) {
              print("长按图片啦:\(index)")
        }
       
        func imageViewerViewController(_ viewController: YUImageViewerViewController, didShowAt index: Int, model: YUImageViewerModel) {
            
        }
        func imageViewerViewController(_ viewController: YUImageViewerViewController, willShowAt index: Int, model: YUImageViewerModel) {
            
        }
        func imageViewerViewController(_ viewController: YUImageViewerViewController, didDismissAt index: Int, model: YUImageViewerModel) {
            
        }
        func imageViewerViewController(_ viewController: YUImageViewerViewController, willDismissAt index: Int, model: YUImageViewerModel) {
            
        }

    }

