//
//  ViewController.swift
//  CircleProgressBarExample
//
//  Created by Liu Chuan on 2018/2/17.
//  Copyright © 2018 LC. All rights reserved.
//

import UIKit


/// url address
private let urlString = "http://220.170.49.106/3/m/p/i/r/mpirjwpspciasbznoqvzllappypfoz/he.yinyuetai.com/2CE5013B1378C6FD189DB4146E24F7AF.flv?sc=2a836e274011540b&br=3132&vid=549027&aid=79&area=KR&vst=2"


class ViewController: UIViewController {
    
    /// CAShapeLayer定义
    private var shapeLayer: CAShapeLayer = CAShapeLayer()
    
    /// 脉动层
    private var pulsatigLayer: CAShapeLayer = CAShapeLayer()
    
    /// 百分比标签
    private var percentageLabel: UILabel = {
        let label = UILabel()
        label.text = "Start"
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 32)
        label.textColor = .white
        return label
    }()
    

    // MARK: - View life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configNotificationObservers()
        configCircleLayers()
        configPercentageLabel()
        view.backgroundColor = UIColor.backgroundColor
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }

    /// 配置通知观察者
    private func configNotificationObservers() {
        //注册程序进入前台通知
        NotificationCenter.default.addObserver(self, selector: #selector(handleEnter), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    /// 处理通知
    @objc private func handleEnter() {
        animatePulsatingLayer()
    }
    
    /// 配置圆形图层
    private func configCircleLayers() {
        
        pulsatigLayer = createCircleShapeLayer(strokeColor: .clear, fillColor: .pulsatingFillColor)
        view.layer.addSublayer(pulsatigLayer)
        
        animatePulsatingLayer()
        
        /// 跟踪图层
        let trackLayer = createCircleShapeLayer(strokeColor: .trackStrokeColor, fillColor: .backgroundColor)
        view.layer.addSublayer(trackLayer)
        shapeLayer = createCircleShapeLayer(strokeColor: .outlineStrokeColor, fillColor: .clear)
        
        // 将动画向左转90度
        shapeLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
        shapeLayer.strokeEnd = 0
        view.layer.addSublayer(shapeLayer)
    }
    
    /// 动画脉动层
    private func animatePulsatingLayer() {
        let animation = CABasicAnimation(keyPath: "transform.scale")
        // 动画当前值
        animation.toValue = 1.3
        // 动画持续时间
        animation.duration = 0.8
        // 动画的速度变化
        animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeOut)
        // 动画结束时是否执行逆动画
        animation.autoreverses = true
        // 重复次数
        animation.repeatCount = Float.infinity
        // 添加动画
        pulsatigLayer.add(animation, forKey: "pulsing")
    }
    
    /// 配置百分比标签
    private func configPercentageLabel() {
        percentageLabel.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        percentageLabel.center = view.center
        view.addSubview(percentageLabel)
    }
    
    /// 动画圈
    private func animateCircle() {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.toValue = 1
        basicAnimation.duration = 2
        basicAnimation.fillMode = CAMediaTimingFillMode.forwards
        basicAnimation.isRemovedOnCompletion = false
        
        shapeLayer.add(basicAnimation, forKey: "urSoBasic")
    }
    
    /// 开始下载文件
    private func beginDownloadingFile() {
        print("start working ...")
        shapeLayer.strokeEnd = 0
        let configuration = URLSessionConfiguration.default
        let operationQueue = OperationQueue()
        // 创建会话对象
        let urlSession = URLSession(configuration: configuration, delegate: self, delegateQueue: operationQueue)
        guard let url = URL(string: urlString) else { return }
        // 根据会话对象创建task
        let downloadTask = urlSession.downloadTask(with: url)
        // 使用resume方法启动任务
        downloadTask.resume()
    }
    
    /// 点击事件
    @objc private func handleTap() {
        
        beginDownloadingFile()
//        animateCircle()
    }
}


// MARK: - custom method
extension ViewController {
    
    /// 创建圆形图层(ShapeLayer)
    ///
    /// - Parameters:
    ///   - strokeColor: 绘制颜色
    ///   - fillColor: 填充颜色
    /// - Returns: CAShapeLayer
    private func createCircleShapeLayer(strokeColor: UIColor, fillColor: UIColor) -> CAShapeLayer {
        let layer = CAShapeLayer()
        let circularPath = UIBezierPath(arcCenter: .zero, radius: 100, startAngle: 0, endAngle: 2 * CGFloat.pi, clockwise: true)
        layer.path = circularPath.cgPath
        layer.strokeColor = strokeColor.cgColor
        layer.lineWidth = 20
        layer.fillColor = fillColor.cgColor
        layer.lineCap = CAShapeLayerLineCap.round
        layer.position = view.center
        return layer
    }
}

// MARK: - URLSessionDownloadDelegate
extension ViewController : URLSessionDownloadDelegate {
    
    /// 下载完成
    ///
    /// - Parameters:
    ///   - session: NSURLSession
    ///   - downloadTask: 里面包含请求信息，以及响应信息
    ///   - location: 下载后自动帮我保存的地址
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        print ("Finished downloading file. Save at\(location.path)")
    }
    
    /// 监听下载进度
    ///
    /// - Parameters:
    ///   - session: 当前会话
    ///   - downloadTask: 当前会话任务
    ///   - bytesWritten: 本次写入数据大小
    ///   - totalBytesWritten: 已经写入数据大小
    ///   - totalBytesExpectedToWrite: 要下载的文件总大小
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        
        //下载进度
        print("total: \(totalBytesExpectedToWrite), current: \(totalBytesWritten)")
        
        /// 百分比
        let percentage = CGFloat(totalBytesWritten) / CGFloat(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.percentageLabel.text = "\(Int(percentage * 100))%"
            self.shapeLayer.strokeEnd = percentage
        }
    }
    
}


// MARK: - UIColor Extension
extension UIColor {
    
    static func rgb(r: CGFloat, g: CGFloat, b: CGFloat) -> UIColor {
        return UIColor(displayP3Red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
    static let backgroundColor = UIColor.rgb(r: 21, g: 22, b: 33)
    static let outlineStrokeColor = UIColor.rgb(r: 234, g: 46, b: 111)
    static let trackStrokeColor = UIColor.rgb(r: 56, g: 25, b: 49)
    static let pulsatingFillColor = UIColor.rgb(r: 86, g: 30, b: 63)
}
