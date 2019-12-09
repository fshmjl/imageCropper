//
//  RImageCropperViewController.swift
//  tengmaoProduct
//
//  Created by RPK on 2019/12/6.
//  Copyright © 2019 Teng Mao Technology. All rights reserved.
//


import UIKit

let SCALE_FRAME_Y    = 100.0
let BOUNDCE_DURATION = 0.3

@objc protocol RImageCropperDelegate : NSObjectProtocol {
    func imageCropper(cropperViewController:RImageCropperViewController, didFinished editImg:UIImage)

    func imageCropperDidCancel(cropperViewController:RImageCropperViewController)
}

class RImageCropperViewController: UIViewController {

    var originalImage:UIImage?
    var editedImage:UIImage?

    var showImgView:UIImageView?
    var overlayView:UIView?
    var ratioView:UIView?

    var oldFrame:CGRect?
    var largeFrame:CGRect?
    var limitRatio:CGFloat?

    var latestFrame:CGRect?
    var cropFrame:CGRect?

    var tag:NSInteger?

    var delegate:RImageCropperDelegate?

    deinit {
        self.originalImage = nil
        self.showImgView   = nil
        self.editedImage   = nil
        self.overlayView   = nil
        self.ratioView       = nil
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    convenience init(originalImage:UIImage, cropFrame:CGRect, limitScaleRatio:CGFloat) {
        self.init(nibName: nil, bundle: nil)
      
        self.cropFrame = cropFrame
        self.limitRatio  = limitScaleRatio
        self.originalImage = self.fixOrientation(srcImg: originalImage)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.initView()
        self.initControlBtn()
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func shouldAutorotate() -> Bool {
        return false
    }

//    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
//        return UIInterfaceOrientation.Unknown
//    }
//
//    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
//        return UIInterfaceOrientationMask.All
//    }

//    initView
    func initView() {
        self.view.backgroundColor = UIColor.black

        self.showImgView = UIImageView(frame: CGRect.init(x:0, y:0, width: kScreenWidth, height:kScreenHeight))
        self.showImgView?.center                           = view.center
        self.showImgView?.isMultipleTouchEnabled   = true
        self.showImgView?.isUserInteractionEnabled = true
        self.showImgView?.image                              = self.originalImage
        self.showImgView?.isUserInteractionEnabled = true
        self.showImgView?.isMultipleTouchEnabled   = true

      // scale to fit the screen
//        let oriWidth = self.cropFrame!.size.width
        let oriWidth  = kScreenWidth
        let oriHeight = (self.originalImage?.size.height)! * (oriWidth / (self.originalImage?.size.width)!)
        let oriX = (self.cropFrame?.origin.x)! + ((self.cropFrame?.size.width)! - oriWidth) / 2
        let oriY = (self.cropFrame?.origin.y)! + ((self.cropFrame?.size.height)! - oriHeight) / 2

        self.oldFrame = CGRect.init(x:oriX, y:oriY, width: oriWidth, height:oriHeight)
        self.latestFrame = self.oldFrame
        self.showImgView?.frame = self.oldFrame!

        self.largeFrame = CGRect.init(x: 0, y: 0, width: self.limitRatio! * self.oldFrame!.size.width, height: self.limitRatio! * self.oldFrame!.size.height)

        self.addGestureRecognizers()
        self.view.addSubview(self.showImgView!)

        self.overlayView = UIView(frame: self.view.bounds)
        self.overlayView?.alpha = 0.5
        self.overlayView?.backgroundColor = UIColor.black
        self.overlayView?.isUserInteractionEnabled = false
        self.overlayView?.autoresizingMask = [UIView.AutoresizingMask.flexibleHeight, UIView.AutoresizingMask.flexibleWidth]

        self.view.addSubview(self.overlayView!)

        self.ratioView = UIView(frame: self.cropFrame!)
        self.ratioView?.layer.borderColor = UIColor.yellow.cgColor
        self.ratioView?.layer.borderWidth = 1.0
        self.view.addSubview(self.ratioView!)

        self.overlayClipping()
    }

    func initControlBtn() {
        let cancelBtn = UIButton(frame: CGRect.init(x: 0, y: self.view.frame.size.height - 50.0 - kTabbarSafeBottomMargin, width: 100, height: 50))
        cancelBtn.backgroundColor = UIColor.black
        cancelBtn.titleLabel?.textColor = UIColor.white
        cancelBtn.setTitle("取消", for: UIControl.State.normal)
        cancelBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        cancelBtn.titleLabel?.textAlignment = NSTextAlignment.center
        cancelBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        cancelBtn.titleLabel?.numberOfLines = 0
        cancelBtn.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        cancelBtn.addTarget(self, action: #selector(cancel(sender:)), for: .touchUpInside)
        self.view.addSubview(cancelBtn)

        let confirmBtn:UIButton = UIButton(frame: CGRect.init(x: self.view.frame.size.width - 100.0, y: self.view.frame.size.height - 50.0 - kTabbarSafeBottomMargin, width: 100, height: 50))
        confirmBtn.backgroundColor = UIColor.black
        confirmBtn.titleLabel?.textColor = UIColor.white
        confirmBtn.setTitle("确认", for: UIControl.State.normal)
        confirmBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18.0)
        confirmBtn.titleLabel?.textAlignment = NSTextAlignment.center
        confirmBtn.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        confirmBtn.titleLabel?.numberOfLines = 0
        confirmBtn.titleEdgeInsets = UIEdgeInsets(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0)
        confirmBtn.addTarget(self, action: #selector(confirm(sender:)), for: .touchUpInside)
        self.view.addSubview(confirmBtn)
    }

  // private func

    @objc func cancel(sender:AnyObject) {
        if self.delegate != nil {
            self.delegate!.imageCropperDidCancel(cropperViewController: self)
        }
    }

    @objc func confirm(sender:AnyObject) {
        if self.delegate != nil {
            self.delegate!.imageCropper(cropperViewController: self, didFinished: self.getSubImage())
        }
    }

    func overlayClipping() {
        let maskLayer = CAShapeLayer()
        let path = CGMutablePath()

        let path1 = CGPath.init(rect: CGRect.init(x: 0, y: 0, width: self.ratioView!.frame.origin.x, height: self.overlayView!.frame.size.height), transform: nil)
        path.addPath(path1)

        let path2 = CGPath.init(rect: CGRect.init(x: self.ratioView!.frame.origin.x + self.ratioView!.frame.size.width, y: 0, width: self.overlayView!.frame.size.width - self.ratioView!.frame.origin.x - self.ratioView!.frame.size.width, height: self.overlayView!.frame.size.height), transform: nil)
        path.addPath(path2)

        let path3 = CGPath.init(rect: CGRect.init(x: 0, y: 0, width: self.overlayView!.frame.size.width, height: self.ratioView!.frame.origin.y), transform: nil)
        path.addPath(path3)
        // Top side of the ratio view

        let path4 = CGPath.init(rect: CGRect.init(x: 0, y: self.ratioView!.frame.origin.y + self.ratioView!.frame.size.height, width: self.overlayView!.frame.size.width, height: self.overlayView!.frame.size.height - self.ratioView!.frame.origin.y + self.ratioView!.frame.size.height), transform: nil)
        path.addPath(path4)
        // Bottom side of the ratio view

        maskLayer.path = path
        self.overlayView?.layer.mask = maskLayer
        path.closeSubpath()
    }

  // register all gestures
    func addGestureRecognizers() {
        // pinch
        let pinchGestureRecognizer:UIPinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(pinchView(pinchGestureRecognizer:)))
        self.view.addGestureRecognizer(pinchGestureRecognizer)

        // pan
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panView(panGestureRecognizer:)))
        self.view.addGestureRecognizer(panGestureRecognizer)
    }

  // pinch gesture handler
    @objc func pinchView(pinchGestureRecognizer:UIPinchGestureRecognizer) {
        let view = self.showImgView!
        if pinchGestureRecognizer.state == UIGestureRecognizer.State.began || pinchGestureRecognizer.state == UIGestureRecognizer.State.changed {
            view.transform = view.transform.scaledBy(x: pinchGestureRecognizer.scale, y: pinchGestureRecognizer.scale)
            pinchGestureRecognizer.scale = 1
        }
        else if pinchGestureRecognizer.state == UIGestureRecognizer.State.ended {
            var newFrame = self.showImgView!.frame
            newFrame = self.handleScaleOverflow(newFrame: newFrame)
            newFrame = self.handleBorderOverflow(newFrame: newFrame)

            UIView.animate(withDuration: BOUNDCE_DURATION, animations: { () -> Void in
                self.showImgView!.frame = newFrame
                self.latestFrame = newFrame
            })
        }
    }

//    pan gesture handler
    @objc func panView(panGestureRecognizer:UIPanGestureRecognizer) {
        let view = self.showImgView!
        if panGestureRecognizer.state == UIGestureRecognizer.State.began || panGestureRecognizer.state == UIGestureRecognizer.State.changed {
            
            let absCenterX = self.cropFrame!.origin.x + self.cropFrame!.size.width / 2
            let absCenterY = self.cropFrame!.origin.y + self.cropFrame!.size.height / 2
            let scaleRatio = self.showImgView!.frame.size.width / self.cropFrame!.size.width
            let acceleratorX = 1 - abs(absCenterX - view.center.x) / (scaleRatio * absCenterX)
            let acceleratorY = 1 - abs(absCenterY - view.center.y) / (scaleRatio * absCenterY)
            let translation = panGestureRecognizer.translation(in: view.superview)
            view.center = CGPoint.init(x:view.center.x + translation.x * acceleratorX, y:view.center.y + translation.y * acceleratorY)
            panGestureRecognizer.setTranslation(CGPoint.zero, in: view.superview)
        }
        else if panGestureRecognizer.state == UIGestureRecognizer.State.ended {
            var newFrame = self.showImgView!.frame
            newFrame = self.handleBorderOverflow(newFrame: newFrame)
            UIView.animate(withDuration: BOUNDCE_DURATION, animations: { () -> Void in
            self.showImgView!.frame = newFrame
            self.latestFrame = newFrame
        })
      }
    }

    func handleScaleOverflow(newFrame:CGRect) -> CGRect {
        let oriCenter = CGPoint.init(x:newFrame.origin.x + newFrame.size.width / 2, y:newFrame.origin.y + newFrame.size.height / 2)
        var newFrame1 = newFrame
        if newFrame.size.width < self.oldFrame!.size.width {
            newFrame1 = self.oldFrame!
        }
        if newFrame.size.width > self.largeFrame!.size.width {
            newFrame1 = self.largeFrame!
        }
        newFrame1.origin.x = oriCenter.x - newFrame.size.width / 2
        newFrame1.origin.y = oriCenter.y - newFrame.size.height / 2
        return newFrame1
    }

    func handleBorderOverflow(newFrame:CGRect) -> CGRect {
        var newFrame1 = newFrame
        if newFrame.origin.x > self.cropFrame!.origin.x {
            newFrame1.origin.x = self.cropFrame!.origin.x
        }
        if newFrame.maxX < self.cropFrame!.size.width {
            newFrame1.origin.x = self.cropFrame!.size.width - newFrame.size.width
        }

        if newFrame.origin.y > self.cropFrame!.origin.y {
            newFrame1.origin.y = self.cropFrame!.origin.y
        }
        if newFrame.maxY < self.cropFrame!.origin.y + self.cropFrame!.size.height {
            newFrame1.origin.y = self.cropFrame!.origin.y + self.cropFrame!.size.height - newFrame.size.height
        }

        if self.showImgView!.frame.size.width > self.showImgView!.frame.size.height && newFrame.size.height <= self.cropFrame!.size.height {
            newFrame1.origin.y = self.cropFrame!.origin.y + (self.cropFrame!.size.height - newFrame.size.height) / 2
        }
        return newFrame1
    }

    func getSubImage() -> UIImage {
        let squareFrame = self.cropFrame!
        let scaleRatio = self.latestFrame!.size.width / self.originalImage!.size.width
        var x = (squareFrame.origin.x - self.latestFrame!.origin.x) / scaleRatio
        var y = (squareFrame.origin.y - self.latestFrame!.origin.y) / scaleRatio
        var w = squareFrame.size.width / scaleRatio
        var h = squareFrame.size.height / scaleRatio
        if self.latestFrame!.size.width < self.cropFrame!.size.width {
            let newW = self.originalImage!.size.width
            let newH = newW * (self.cropFrame!.size.height / self.cropFrame!.size.width)
            x = 0;
            y = y + (h - newH) / 2
            w = newH
            h = newH
        }
        if self.latestFrame!.size.height < self.cropFrame!.size.height {
            let newH = self.originalImage!.size.height
            let newW = newH * (self.cropFrame!.size.width / self.cropFrame!.size.height)
            x = x + (w - newW) / 2
            y = 0
            w = newH
            h = newH
        }

        let myImageRect = CGRect.init(x: x, y: y, width: w, height: h)
        let imageRef = self.originalImage!.cgImage!
        let subImageRef = imageRef.cropping(to: myImageRect)
        let size:CGSize = CGSize.init(width: myImageRect.size.width, height: myImageRect.size.height)
        UIGraphicsBeginImageContext(size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.draw(subImageRef!, in: myImageRect)
        let smallImage = UIImage.init(cgImage: subImageRef!)
        UIGraphicsEndImageContext()
        return smallImage
    }

//    orientation
    func fixOrientation(srcImg:UIImage) -> UIImage {
        if srcImg.imageOrientation == UIImage.Orientation.up {
          return srcImg
        }
        var transform = CGAffineTransform.identity
        switch srcImg.imageOrientation {
        case .down, .downMirrored:
              transform = transform.translatedBy(x: srcImg.size.width, y: srcImg.size.height)
              transform = transform.rotated(by: CGFloat(Double.pi))
        case .left, .leftMirrored:
              transform = transform.translatedBy(x: srcImg.size.width, y: 0)
              transform = transform.rotated(by: CGFloat(Double.pi/2))
        case .right, .rightMirrored:
              transform = transform.translatedBy(x: 0, y: srcImg.size.height)
              transform = transform.rotated(by: CGFloat(-Double.pi/2))
        case .up, .upMirrored:
              break
        @unknown default:
            break
        }
        switch srcImg.imageOrientation {
        case .upMirrored, .downMirrored:
              transform = transform.translatedBy(x: srcImg.size.width, y: 0)
              transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
              transform = transform.translatedBy(x: srcImg.size.height, y: 0)
              transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
              break
        @unknown default:
            break
        }

        // 上下文
        let ctx = CGContext.init(data: nil, width: Int(srcImg.size.width), height: Int(srcImg.size.height), bitsPerComponent: srcImg.cgImage!.bitsPerComponent, bytesPerRow: srcImg.cgImage!.bytesPerRow, space: srcImg.cgImage!.colorSpace ?? CGColorSpaceCreateDeviceRGB(), bitmapInfo: srcImg.cgImage!.bitmapInfo.rawValue)
        ctx!.concatenate(transform)

        switch srcImg.imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
              ctx?.draw(srcImg.cgImage!, in: CGRect.init(x: 0, y: 0, width: srcImg.size.height, height: srcImg.size.width))
        default:
              ctx?.draw(srcImg.cgImage!, in: CGRect.init(x: 0, y: 0, width: srcImg.size.width, height: srcImg.size.height))
        }

        let cgImg:CGImage = ctx!.makeImage()!
        let img:UIImage = UIImage(cgImage: cgImg)

//        ctx!.closePath()
        return img
  }

}
