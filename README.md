# YUImageViewer
**一款类似于微信QQ的大图查看器**

![](https://raw.githubusercontent.com/fengyu122/YUImageViewer/master/screenshot.gif)

## Require
* Xcode 8
* Swift 3
* iOS8 and later

## Features
* 支持手势放大、缩小
* 支持横竖屏切换
* 不支持gif图片
* 类似于QQ微信的效果

## Usage
~~~
let model1=YUImageViewerModel()

//也就是那张小图。可选。nil值将以淡入淡出的方式显示
model1.placeholder=imageView.image

//frame是点击View相对于当前ViewController的!
//若该View的superView不是ViewController的View。请使用convert函数转换。nil值将以淡入淡出的效果显示
model1.frame=view.convert(cell.imageView.frame, from: cell.contentView)

//url(option)
model1.url=URL.init(string: "http://...")

let model2=YUImageViewerModel()
model2.placeholder=...
mdoel2.frame=...

let models=[model1,model2]

//currentSelect表示一打开就显示第几张图片
let vc=YUImageViewerViewController(models: models, currentSelect: index delegate: self)

present(vc, animated: true, completion: nil)
~~~

***这个框架并不带有图片下载功能。你还需要用你项目中的图片下载框架来实现图片的下载功能。***

### YUImageViewerViewControllerDelegate

下载图片的代理。**必须实现**。你可以选择你项目中的图片下载框架。**下载完成后执行 complete() 这个closure。传true表示下载成功 传false表示下载失败**
~~~
func imageViewerViewController(_ viewController: YUImageViewerViewController, downloadImageAt index: Int, imageView: UIImageView, model: YUImageViewerModel, complete: @escaping DownloadCompleteBlock) {
    //请使用项目中的图片下载框架进行下载。这里只是简单的示例
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

    // 使用SDWebImage下载代码示例
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

~~~

*其它请根据需要决定是否实现*
~~~
func imageViewerViewController(_ viewController: YUImageViewerViewController, onLongPressAt index: Int, image: UIImage?, model: YUImageViewerModel) {
      //在这里。你可以对长按的图片进行操作。比如保存图片或者分享
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
~~~

## Contact
***QQ:535920015***

如您在使用过程中有任何问题或者有任何建议，请通过QQ或者在github中提出issue来联系我们

## License

*YUImageViewer is licensed under the [MIT license](https://github.com/fengyu122/YUImageViewer/blob/master/LICENSE).*
