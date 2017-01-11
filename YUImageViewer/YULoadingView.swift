//
//  YULoadingView.swift
//  YUImageViewer
//
//  Created by yu on 2017/1/9.
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

class YULoadingView: UIView {
    let lineWidth:CGFloat=2.5
    override func draw(_ rect: CGRect) {
        let ctx=UIGraphicsGetCurrentContext()
        let arcCenter=CGPoint.init(x: rect.maxX/2, y: rect.maxY/2)
        let radius=(rect.width-lineWidth)/2
        let circlePath=UIBezierPath.init(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2*M_PI), clockwise: true)
        ctx?.setStrokeColor(UIColor.init(red: 60/255.0, green: 60/255.0, blue: 60/255.0, alpha: 0.9).cgColor)
        ctx?.setLineWidth(lineWidth)
        ctx?.addPath(circlePath.cgPath)
        ctx?.strokePath()
        
        let sectorialPath=UIBezierPath.init(arcCenter: arcCenter, radius: radius, startAngle: 0, endAngle: CGFloat(2*M_PI*0.36), clockwise: true)
        ctx?.setStrokeColor(UIColor.init(red: 241/255.0, green: 241/255.0, blue: 241/255.0, alpha: 1).cgColor)
        ctx?.addPath(sectorialPath.cgPath)
        ctx?.strokePath()
        
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor=UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    func start()
    {
        let animation=CAKeyframeAnimation.init(keyPath: "transform")
        animation.keyTimes=[0,0.25,0.5,0.75,1]
        animation.values=[CATransform3DMakeRotation(0, 0, 0, 1),CATransform3DMakeRotation(CGFloat(Float(M_PI_2)), 0, 0, 1),CATransform3DMakeRotation(CGFloat(Float(M_PI)), 0, 0, 1),CATransform3DMakeRotation(CGFloat(Float(M_PI_2+M_PI)), 0, 0, 1),CATransform3DMakeRotation(CGFloat(Float(2*M_PI)), 0, 0, 1)]
        animation.fillMode=kCAFillModeForwards
        animation.duration=0.7
        animation.repeatCount=Float.greatestFiniteMagnitude
        layer.add(animation, forKey: "transform")
    }
    func stop()
    {
        layer.removeAnimation(forKey: "transform")
    }
    func dismiss()
    {
        stop()
        removeFromSuperview()
    }
    class func show(in view:UIView)->YULoadingView
    {
        let loadingView=YULoadingView.init()
        view.addSubview(loadingView)
        view.bringSubview(toFront: loadingView)
        let centerXLayoutConstraint=NSLayoutConstraint.init(item: loadingView, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYLayoutConstraint=NSLayoutConstraint.init(item: loadingView, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
        loadingView.translatesAutoresizingMaskIntoConstraints=false
        view.addConstraints([centerXLayoutConstraint,centerYLayoutConstraint])  //use autoLayout support rotate
        loadingView.start()
        return loadingView
    }
    override var intrinsicContentSize: CGSize
    {
        return CGSize.init(width: 20, height: 20)
    }
    class func dismissAll(in view:UIView)
    {
        for subView in view.subviews
        {
            if let loadView=subView as? YULoadingView
            {
                loadView.dismiss()
            }
        }
    }
}
