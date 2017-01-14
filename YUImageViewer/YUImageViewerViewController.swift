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

@objc   protocol YUImageViewerViewControllerDelegate:NSObjectProtocol {
    @objc  optional func  imageViewerViewController(_ viewController:YUImageViewerViewController , onLongPressAt index:Int ,image:UIImage? ,model:YUImageViewerModel)
    @objc optional func  imageViewerViewController(_ viewController:YUImageViewerViewController, didShowAt index:Int ,model :YUImageViewerModel)
    @objc optional func  imageViewerViewController(_ viewController:YUImageViewerViewController, willShowAt index:Int ,model:YUImageViewerModel)
    @objc optional func imageViewerViewController(_ viewController:YUImageViewerViewController, didDismissAt index:Int ,model:YUImageViewerModel)
    @objc optional func imageViewerViewController(_ viewController:YUImageViewerViewController, willDismissAt index:Int ,model:YUImageViewerModel)
    func imageViewerViewController(_ viewController:YUImageViewerViewController , downloadImageAt index:Int , imageView:UIImageView , model:YUImageViewerModel,complete:@escaping DownloadCompleteBlock)
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
        collectionView.showsHorizontalScrollIndicator=false
        collectionView.showsVerticalScrollIndicator=false
        collectionView.translatesAutoresizingMaskIntoConstraints=false
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
    private var hideNotCurrentCell=false
        {
        didSet
        {
            collectionView.reloadData()
        }
    }
    private  let  transitonAnimation=YUTransitonAnimation.init()
    private var canUpdateCurrentIndex=true
    override public var shouldAutorotate: Bool
    {
        return true
    }
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask
    {
        return UIInterfaceOrientationMask.allButUpsideDown
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
        view.backgroundColor=UIColor.black
        view.addSubview(collectionView)
        
        view.addSubview(pageControl)
        view.addConstraint(NSLayoutConstraint.init(item: pageControl, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint.init(item: pageControl, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -10))
        pageControl.numberOfPages=models.count
        pageControl.currentPage=currentSelect
        
        UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        
        collectionView.selectItem(at: IndexPath.init(row: currentSelect, section: 0), animated: false, scrollPosition: .left)
        
        UIApplication.shared.setStatusBarHidden(true, with: .fade)
        
    }
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.delegate?.imageViewerViewController?(self, willShowAt: currentSelect ,model:models[currentSelect])
    }
    public override func viewDidDisappear(_ animated: Bool) {
         super.viewDidDisappear(animated)
        self.delegate?.imageViewerViewController?(self, didDismissAt: self.currentSelect,model:models[currentSelect])
    }
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.delegate?.imageViewerViewController?(self, willDismissAt: currentSelect,model:models[currentSelect])
    }
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.delegate?.imageViewerViewController?(self, didShowAt: currentSelect,model:models[currentSelect])
    }
    
    public override var prefersStatusBarHidden: Bool
    {
        return true
    }
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    
    public override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        canUpdateCurrentIndex=false
        hideNotCurrentCell=true
        
        coordinator.animate(alongsideTransition: { [unowned self] (ctx) in
            self.collectionView.collectionViewLayout.invalidateLayout()
            self.collectionView.frame=CGRect.init(origin: CGPoint.zero, size: size)
            self.collectionView.selectItem(at: IndexPath.init(row: self.currentSelect, section: 0), animated: false, scrollPosition: .left)
            
        }) { [unowned self]  (ctx)  in
            self.canUpdateCurrentIndex=true
            self.hideNotCurrentCell=false
            
        }
    }
    private var currentSelect:Int=0
        {
        didSet
        {
            pageControl.currentPage=currentSelect
        }
    }
    weak var delegate:YUImageViewerViewControllerDelegate?
    convenience init(models:[YUImageViewerModel],currentSelect:Int,delegate:YUImageViewerViewControllerDelegate)
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
        cell.isHidden=hideNotCurrentCell && currentSelect != indexPath.row
        return cell
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if canUpdateCurrentIndex
        {
            let offsetX=scrollView.contentOffset.x
            currentSelect=Int(offsetX/scrollView.bounds.width+0.5)
        }
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
        self.delegate?.imageViewerViewController?(self, onLongPressAt: index, image: image ,model:models[index])
    }
    func imageViewerCell(downloadImageAt index: Int, imageView: UIImageView, complete: @escaping DownloadCompleteBlock) {
        self.delegate?.imageViewerViewController(self, downloadImageAt: index, imageView: imageView, model:models[index],complete: complete)
    }
}
