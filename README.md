# YUImageViewer
一款类似于微信QQ的大图查看器

![](https://raw.githubusercontent.com/fengyu122/YUImageViewer/master/screenshot.gif)

### 要求
* Xcode 8
* Swift 3
* iOS8 and later

### 功能
* 支持手势放大、缩小
* 支持横竖屏切换
* 不支持gif图片
* 类似于QQ微信的效果

### 使用
~~~
let model1=YUImageViewerModel()
model1.placeholder=imageView.image //也就是那张小图。可选。nil值将以淡入淡出的方式显示
model1.frame=view.convert(cell.imageView.frame, from: cell.contentView) //frame是点击View相对于当前ViewController的！！！若该View的superView不是ViewController的View。请使用covert函数转换。nil值将以淡入淡出的效果显示

let model2=YUImageViewerModel()
model2.placeholder=...
mdoel2.frame=...

let models=[model1,model2]
let vc=YUImageViewerViewController.init(models: models, currentSelect: indexPath.item, delegate: self)
present(vc, animated: true, completion: nil)
~~~
