//
//  YUImageViewerCell.swift
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


enum YUImageState {
    case downloading
    case downloadFinish
    case downloadFail
}



protocol YUImageViewerCellProtocol:NSObjectProtocol {
    func imageViewerCell(singleTapActionAt index:Int)
    func imageViewerCell(longPressActionAt index:Int, image:UIImage?)
    func imageViewerCell(downloadImageAt index:Int , imageView:UIImageView , complete:@escaping DownloadCompleteBlock)
}

class YUImageViewerCell: UICollectionViewCell,UIScrollViewDelegate {
    weak var delegate:YUImageViewerCellProtocol?
    var index:Int!
    private var state:YUImageState!
        {
        didSet
        {
            switch state! {
            case .downloadFail,.downloading:
                downloadingOrFailAction()
            case .downloadFinish:
                downloadFinishAction()
            }
        }
    }
    
    
    private lazy var scrollView:UIScrollView={
        [unowned self] in
        let scrollView=UIScrollView(frame:self.contentView.bounds)
        scrollView.bouncesZoom=true
        scrollView.delegate=self
        scrollView.contentInset=UIEdgeInsets.zero
        scrollView.minimumZoomScale=self.minimumZoomScale
        scrollView.maximumZoomScale=self.maximumZoomScale
        scrollView.addSubview(self.imageView)
        scrollView.showsHorizontalScrollIndicator=false
        scrollView.showsVerticalScrollIndicator=false
        
        let singleTapGestureRecognizer=UITapGestureRecognizer.init(target: self, action: #selector(YUImageViewerCell.singleTapGestureRecognizerHandle(_:)))
        let doubleTapGestureRecognizer=UITapGestureRecognizer.init(target: self, action: #selector(YUImageViewerCell.doubleTapGestureRecognizerHandle(_:)))
        let longPressGestureRecognize=UILongPressGestureRecognizer.init(target: self, action: #selector(YUImageViewerCell.longPressGestureRecognizerHandle(_:)))
        doubleTapGestureRecognizer.numberOfTapsRequired=2
        singleTapGestureRecognizer.require(toFail: doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(singleTapGestureRecognizer)
        scrollView.addGestureRecognizer(doubleTapGestureRecognizer)
        scrollView.addGestureRecognizer(longPressGestureRecognize)
        
        return scrollView
        
        }()
    var model:YUImageViewerModel!
        {
        didSet
        {
            minimumZoomScale=model.minimumZoomScale
            if model.orientation != UIDevice.current.orientation
            {
                model.orientation=UIDevice.current.orientation
            }
            imageView.image=model.placeholder
            self.downloadImage()
        }
    }
    private func downloadingOrFailAction()
    {
        scrollView.maximumZoomScale=minimumZoomScale
        
        scrollView.setZoomScale(minimumZoomScale, animated: false)
        scrollView.setContentOffset(CGPoint.zero, animated: false)
        YULoadingView.dismissAll(in: self)
        if state == YUImageState.downloading
        {
            let _=YULoadingView.show(in: self)
        }
        
    }
    private func downloadFinishAction()
    {
        YULoadingView.dismissAll(in: self)
        if let scale=model.scale
        {
            scrollView.zoomScale=scale
        }else
        {
            scrollView.setZoomScale(minimumZoomScale, animated: false)
            model.scale=minimumZoomScale
        }
        
        if let contentOffset=model.contentOffset
        {
            scrollView.setContentOffset(contentOffset, animated: false)
        }else
        {
            scrollView.setContentOffset(CGPoint.zero, animated: false)
        }
        
    }
    
    lazy var completeDownloadBlock:DownloadCompleteBlock={
        [weak self] (sucess)  in
        if sucess
        {
            self?.state=YUImageState.downloadFinish
        }else
        {
            self?.state=YUImageState.downloadFail
        }
    }
    
    private func downloadImage()
    {
    
        state=YUImageState.downloading
        delegate?.imageViewerCell(downloadImageAt: index, imageView: imageView, complete: completeDownloadBlock)
    }
    var  minimumZoomScale:CGFloat = 1.0
        {
        didSet
        {
            scrollView.minimumZoomScale=minimumZoomScale
        }
    }
    var maximumZoomScale:CGFloat = 2.0
        {
        didSet
        {
            scrollView.maximumZoomScale=maximumZoomScale
        }
    }
    
    private lazy var imageView:UIImageView={
        [unowned self] in
        let imageView=UIImageView.init()
        imageView.addObserver(self, forKeyPath: "image", options: .new, context: nil)
        imageView.contentMode=UIViewContentMode.scaleAspectFit
        imageView.isUserInteractionEnabled=true
        
        return imageView
        
        }()
    func longPressGestureRecognizerHandle(_ longPressGestureRecognize: UILongPressGestureRecognizer)
    {
        if longPressGestureRecognize.state == UIGestureRecognizerState.began,state == YUImageState.downloadFinish
        {
            self.delegate?.imageViewerCell(longPressActionAt: index,image:imageView.image)
        }
    }
    func singleTapGestureRecognizerHandle(_ tapGestureRecognizer:UITapGestureRecognizer)
    {
        self.delegate?.imageViewerCell(singleTapActionAt: index)
    }
    func doubleTapGestureRecognizerHandle(_ tapGestureRecognizer:UITapGestureRecognizer)
    {
        if state != YUImageState.downloadFinish
        {
            return
        }
        let zoomScale=scrollView.zoomScale
        let location=tapGestureRecognizer.location(in: self.scrollView)
        if zoomScale <= minimumZoomScale
        {
            scrollView.zoom(to: CGRect.init(x: location.x, y: location.y, width: 1, height: 1), animated: true)
        }else
        {
            scrollView.setZoomScale(minimumZoomScale, animated: true)
            
        }
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(scrollView)
        NotificationCenter.default.addObserver(self, selector: #selector(YUImageViewerCell.rotateScreenAction(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    private func setImageViewPosition()
    {
        let centerX=scrollView.contentSize.width > scrollView.bounds.size.width ? scrollView.contentSize.width/2 : scrollView.center.x
        let centerY=scrollView.contentSize.height > scrollView.bounds.size.height ? scrollView.contentSize.height/2 : scrollView.center.y
        imageView.center=CGPoint.init(x: centerX, y: centerY)
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        if state != YUImageState.downloadFinish
        {
            return
        }
        model.scale=scrollView.zoomScale
        setImageViewPosition()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        if state != YUImageState.downloadFinish
        {
            return
        }
        let offset=scrollView.contentOffset
        let maxWidth=scrollView.contentSize.width-scrollView.bounds.width
        let maxHeight=scrollView.contentSize.height-scrollView.bounds.height
        var x=offset.x > maxWidth ? maxWidth : offset.x
        x=x < 0 ? 0 : x
        var y=offset.y > maxHeight ? maxHeight : offset.y
        y=y < 0 ? 0 : y
        model.contentOffset=CGPoint.init(x: x, y: y)
    }
    override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.frame=contentView.bounds
    }
    private func layout(image:UIImage?)
    {
        if let image=imageView.image
        {
            let imageWidth=image.size.width
            let imageHeight=image.size.height
            
            let scrollViewWidth=scrollView.bounds.width
            let scrollViewHeight=scrollView.bounds.height
            
            var multiple:CGFloat!
            
            if scrollViewWidth < scrollViewHeight
            {
                imageView.bounds=CGRect.init(x: 0, y: 0, width: scrollViewWidth, height: imageHeight*(scrollViewWidth/imageWidth))
                multiple=scrollViewHeight/imageView.bounds.height
            }else
            {
                imageView.bounds=CGRect.init(x: 0, y: 0, width: imageWidth*(scrollViewHeight/imageHeight), height: scrollViewHeight)
                multiple=scrollViewWidth/imageView.bounds.width
            }
            
            if multiple > 2
            {
                maximumZoomScale=multiple
            }else
            {
                maximumZoomScale=2
            }
            scrollView.contentSize=imageView.bounds.size
            setImageViewPosition()
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        self.layout(image: imageView.image)
    }
    private func restoreState()
    {
        switch state! {
        case .downloadFail,.downloading:
            downloadingOrFailAction()
        case .downloadFinish:
            downloadFinishAction()
        }
    }
    func rotateScreenAction(_ notification:Notification)
    {
        let device = UIDevice.current
        switch device.orientation {
        case .landscapeLeft where scrollView.frame.height > scrollView.frame.width,
             .landscapeRight where scrollView.frame.height > scrollView.frame.width,
             .portrait where scrollView.frame.width > scrollView.frame.height:
            scrollView.frame=CGRect.init(origin: scrollView.frame.origin, size: CGSize.init(width: scrollView.frame.height, height: scrollView.frame.width))
            
        default:
            break
        }
        
        model.orientation=device.orientation
        imageView.willChangeValue(forKey: "image")
        imageView.didChangeValue(forKey: "image")
        restoreState()
    }
    deinit {
        imageView.removeObserver(self, forKeyPath: "image")
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
}
