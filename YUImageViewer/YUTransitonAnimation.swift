//
//  YUTransitonAnimation.swift
//  YUImageViewer
//
//  Created by yu on 2017/1/10.
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

enum YUTransitonActionType
{
    case present
    case dismiss
}

class YUTransitonAnimation: NSObject,UIViewControllerAnimatedTransitioning {
    var model:YUImageViewerModel?
    var actionType:YUTransitonActionType=YUTransitonActionType.present
    private let duration:TimeInterval=0.25
    var presentOrientation:UIDeviceOrientation?
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return duration
    }
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let fromView=transitionContext.viewController(forKey: .from)!.view!
        let toView=transitionContext.viewController(forKey: .to)!.view!
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
      
        if actionType == YUTransitonActionType.present
        {
            presentOrientation=UIDevice.current.orientation
            if let showModel=model,let frame=showModel.frame,let placeholder=showModel.placeholder
            {
                let imageView=UIImageView.init(image: placeholder)
                imageView.frame=frame
                let bgView=UIView()
                bgView.backgroundColor=UIColor.black
                containerView.addSubview(bgView)
                bgView.frame=fromView.frame
                bgView.alpha=0
                containerView.addSubview(imageView)
                toView.alpha=0
                UIView.animate(withDuration: duration, animations: {
                    self.calculateImageViewFrame(imageView: imageView, view: toView)
                    bgView.alpha=1
                }, completion: { (finish) in
                    toView.alpha=1
                    bgView.removeFromSuperview()
                    imageView.removeFromSuperview()
                    transitionContext.completeTransition(finish)
                })
            }else
            {
                toView.alpha=0
                UIView.animate(withDuration: duration, animations: { 
                    toView.alpha=1
                }, completion: { (finish) in
                    transitionContext.completeTransition(finish)
                })
            }
        }else
        {
            let currentOrientation=UIDevice.current.orientation
            if let model=model,currentOrientation == presentOrientation,let frame=model.frame,let placeholder=model.placeholder
            {
                let bgView=UIView.init(frame: containerView.frame)
                bgView.alpha=1
                bgView.backgroundColor=UIColor.black
                let imageView=UIImageView.init(image: placeholder)
                calculateImageViewFrame(imageView: imageView, view: fromView)
                containerView.addSubview(bgView)
                containerView.addSubview(imageView)
                fromView.alpha=0
                UIView.animate(withDuration: duration, animations: {
                          imageView.frame=frame
                            bgView.alpha=0
                 
                }, completion: { (finish) in
                    imageView.removeFromSuperview()
                    bgView.removeFromSuperview()
                    transitionContext.completeTransition(finish)
                })

            }else
            {
                fromView.alpha=1
                UIView.animate(withDuration: duration, animations: { 
                    fromView.alpha=0
                    fromView.transform=CGAffineTransform.init(scaleX: 2, y: 2)
                }, completion: { (finish) in
                    transitionContext.completeTransition(finish)
                })
            }
        }
}
    private func calculateImageViewFrame(imageView:UIImageView,view:UIView)
    {
        let imageWidth=imageView.image!.size.width
        let imageHeight=imageView.image!.size.height
        let viewWidth=view.bounds.size.width
        let viewHeight=view.bounds.height
        if viewWidth < viewHeight
        {
            imageView.frame=CGRect.init(x: 0, y: 0, width: viewWidth, height: imageHeight*(viewWidth/imageWidth))
            if  imageView.frame.height < viewHeight
            {
                imageView.center=view.center
            }
            
        }else
        {
            imageView.frame=CGRect.init(x: 0, y: 0, width: imageWidth*(viewHeight/imageHeight), height: viewHeight)
            if  imageView.frame.width < viewWidth
            {
                imageView.center=view.center
            }
        }
    }
}
