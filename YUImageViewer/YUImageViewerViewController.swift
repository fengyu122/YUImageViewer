//
//  YUImageViewerViewController.swift
//  YUImageViewer
//
//  Created by yu on 2017/1/8.
//  Copyright © 2017年 yu. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.


import UIKit

@objc   protocol YUImageViewerViewControllerProtocol:NSObjectProtocol {
    @objc  optional func  imageViewerViewController(_ viewController:YUImageViewerViewController , onLongPressAt index:Int ,image:UIImage?)
    func imageViewerViewController(_ viewController:YUImageViewerViewController , downloadImageAt index:Int , imageView:UIImageView , complete:@escaping DownloadCompleteBlock)
}
typealias DownloadCompleteBlock = ((_ sucess:Bool)->())
public class YUImageViewerViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIViewControllerTransitioningDelegate,YUImageViewerCellProtocol {
    private let cellWithReuseIdentifier="YUImageViewerCell"
    private lazy var collectionView:UICollectionView={ [unowned self] in
        let layout=UICollectionViewFlowLayout()
        layout.scrollDirection=UICollectionViewScrollDirection.horizontal
        let collectionView=UICollectionView.init(frame: self.view.bounds, collectionViewLayout: layout)
        collectionView.register(YUImageViewerCell.self, forCellWithReuseIdentifier: self.cellWithReuseIdentifier)
        collectionView.isPagingEnabled=true
        collectionView.dataSource=self
        collectionView.delegate=self
        return collectionView
        }()
    private  lazy var pageControl:UIPageControl={ [unowned self] in
        let pageControl=UIPageControl.init()
        pageControl.pageIndicatorTintColor=UIColor.gray
        pageControl.currentPageIndicatorTintColor=UIColor.white
        pageControl.translatesAutoresizingMaskIntoConstraints=false
        pageControl.hidesForSinglePage=true
        pageControl.isEnabled=false
        return pageControl
    }()

    private  let  transitonAnimation=YUTransitonAnimation.init()
    
    override public var shouldAutorotate: Bool
    {
        return true
    }
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.allButUpsideDown
    }
    
    override public func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        collectionView.collectionViewLayout.invalidateLayout()
        collectionView.frame=view.bounds
        collectionView.selectItem(at: IndexPath.init(row: currentSelect, section: 0), animated: false, scrollPosition: .left)
    }
    var models=[YUImageViewerModel]()
        {
            didSet
            {
                pageControl.numberOfPages=models.count
        }
    }
    override public func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets=false
        view.addSubview(collectionView)
        
        view.addSubview(pageControl)
        view.addConstraint(NSLayoutConstraint.init(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10))
        pageControl.numberOfPages=models.count
        pageControl.currentPage=currentSelect
        
    }
    private var currentSelect:Int=0
        {
            didSet
            {
                pageControl.currentPage=currentSelect
        }
    }
    weak var delegate:YUImageViewerViewControllerProtocol?
    convenience init(models:[YUImageViewerModel],currentSelect:Int,delegate:YUImageViewerViewControllerProtocol)
    {
        self.init()
        self.models=models
        self.delegate=delegate
        self.currentSelect=currentSelect
        transitioningDelegate=self
        
    }
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitonAnimation.actionType=YUTransitonActionType.present
        transitonAnimation.model=models[currentSelect]
        return transitonAnimation
    }
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transitonAnimation.actionType=YUTransitonActionType.dismiss
        transitonAnimation.model=models[currentSelect]
        return transitonAnimation
    }
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return models.count
    }
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell=collectionView.dequeueReusableCell(withReuseIdentifier: cellWithReuseIdentifier, for: indexPath) as! YUImageViewerCell
        cell.delegate=self
        cell.index=indexPath.item
        cell.model=models[indexPath.row]
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return view.bounds.size
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetX=scrollView.contentOffset.x
        currentSelect=Int(offsetX/scrollView.bounds.width+0.5)
       
    }
    func imageViewerCell(singleTapActionAt index: Int) {
        dismiss(animated: true) { [unowned self] in
            for model in self.models
            {
                model.clearState()
            }
        }
    }
    func imageViewerCell(longPressActionAt index: Int, image: UIImage?) {
        self.delegate?.imageViewerViewController?(self, onLongPressAt: index, image: image)
    }
    func imageViewerCell(downloadImageAt index: Int, imageView: UIImageView, complete: @escaping DownloadCompleteBlock) {
         self.delegate?.imageViewerViewController(self, downloadImageAt: index, imageView: imageView, complete: complete)
    }
}
