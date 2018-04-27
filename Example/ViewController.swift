//
//  ViewController.swift
//  Example
//
//  Created by 宇宙超级无敌可爱美少女 on 2018/4/26.
//  Copyright © 2018年 宇宙超级无敌可爱美少女. All rights reserved.
//

import UIKit
import CameraRecognition

let ScreenWidth = UIScreen.main.bounds.width
let ScreenHeight = UIScreen.main.bounds.height

class ViewController: UIViewController {
  var cameraView: CameraView!
  var predicationViews: [UIView] = []
  var predicationKey: String = "yes"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cameraView = CameraView(frame: view.frame)
    cameraView.delegate = self
    cameraView.predicationKey = predicationKey
    cameraView.screenRatio = [4, 3]
    cameraView.backgroundColor = .black
    cameraView.overlayPath = createBezierPath()
    cameraView.scanAnimationDirection = .horizontal
    view.addSubview(cameraView)    
  }
  
  private func _updatePredicationViews(predicationValues values: [AnyHashable : Any]) {
    let font = UIFont.systemFont(ofSize: 14, weight: .regular)
    let fontAttributes = [NSAttributedStringKey.font: font]
    var index = 0
    for (key, value) in values {
      let text = NSString(string: "\(key): \(value)")
      let size = text.size(withAttributes: fontAttributes)
      let height = size.height + 12
      let _label = UILabel(frame: CGRect(origin: CGPoint(x: 20, y: CGFloat(index) * (height + 6) + 30), size: CGSize(width: size.width + 12, height: height)))
      _label.text = "\(key): \(value)"
      _label.font = font
      _label.textColor = .white
      _label.backgroundColor = UIColor.black.withAlphaComponent(0.6)
      _label.layer.cornerRadius = 8
      _label.textAlignment = .center
      _label.clipsToBounds = true
      view.addSubview(_label)
      predicationViews.append(_label)
      index += 1
    }
  }
  
  private func _removePredicationViews() {
    predicationViews.forEach { view in
      view.removeFromSuperview()
    }
    
    predicationViews.removeAll()
  }
  
  private func createBezierPath() -> UIBezierPath {
    // create a new path
    let path = UIBezierPath()
    //segment 1: line
    path.move(to: CGPoint(x: 50.0 / 375 * ScreenWidth, y: 524.0 / 667 * ScreenHeight))
    //segment 2: line
    path.addLine(to: CGPoint(x: 50.0 / 375 * ScreenWidth, y: 425.0 / 667 * ScreenHeight))
    //segment 3: arc
    path.addArc(withCenter: CGPoint(x: 66.0 / 375 * ScreenWidth, y: 425.0 / 667 * ScreenHeight),
                radius: 16.0 / 375 * ScreenWidth, startAngle: CGFloat(Double.pi),
                endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
    //segment 4: line
    path.addLine(to: CGPoint(x: 66.0 / 375 * ScreenWidth, y: 409.0 / 667 * ScreenHeight))
    //segment 5: line
    path.addLine(to: CGPoint(x: 99.0 / 375 * ScreenWidth, y: 409.0 / 667 * ScreenHeight))
    
    path.addArc(withCenter: CGPoint(x: 99.0 / 375 * ScreenWidth, y: 360.0 / 667 * ScreenHeight),
                radius: 49.0 / 375 * ScreenWidth, startAngle: CGFloat(Double.pi / 2) ,
                endAngle: CGFloat(0), clockwise: false)
    path.addLine(to: CGPoint(x: 148.0 / 375 * ScreenWidth, y: 360.0 / 667 * ScreenHeight))
    
    path.addLine(to: CGPoint(x: 148.0 / 375 * ScreenWidth, y: 326.0 / 667 * ScreenHeight))
    
    path.addArc(withCenter: CGPoint(x: 99.0 / 375 * ScreenWidth, y: 326.0 / 667 * ScreenHeight),
                radius: 49.0 / 375 * ScreenWidth, startAngle: CGFloat(0) ,
                endAngle: CGFloat(3 * Double.pi / 2), clockwise: false)
    
    path.addLine(to: CGPoint(x: 66.0 / 375 * ScreenWidth, y: 277.0 / 667 * ScreenHeight))
    
    path.addArc(withCenter: CGPoint(x: 66.0 / 375 * ScreenWidth, y: 261.0 / 667 * ScreenHeight),
                radius: 16.0 / 375 * ScreenWidth, startAngle: CGFloat(Double.pi / 2) ,
                endAngle: CGFloat(Double.pi), clockwise: true)
    
    path.addLine(to: CGPoint(x: 50.0 / 375 * ScreenWidth, y: 161.0 / 667 * ScreenHeight))
    
    path.addArc(withCenter: CGPoint(x: 66.0 / 375 * ScreenWidth, y: 161.0 / 667 * ScreenHeight),
                radius: 16.0 / 375 * ScreenWidth, startAngle: CGFloat(Double.pi) ,
                endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
    
    path.addLine(to: CGPoint(x: 99.0 / 375 * ScreenWidth, y: 145.0 / 667 * ScreenHeight))
    
    path.addArc(withCenter: CGPoint(x: 99.0 / 375 * ScreenWidth, y: 96.0 / 667 * ScreenHeight),
                radius: 49.0 / 375 * ScreenWidth, startAngle: CGFloat(Double.pi / 2) ,
                endAngle: CGFloat(0), clockwise: false)
    
    path.addLine(to: CGPoint(x: 148.0 / 375 * ScreenWidth, y: 46.0 / 667 * ScreenHeight))
    path.addArc(withCenter: CGPoint(x: 164.0 / 375 * ScreenWidth, y: 46),
                radius: 16.0 / 375 * ScreenWidth, startAngle: CGFloat(Double.pi) ,
                endAngle: CGFloat(3 * Double.pi / 2), clockwise: true)
    path.addLine(to: CGPoint(x: 236.0 / 375 * ScreenWidth, y: 30))
    path.addArc(withCenter: CGPoint(x: 236.0 / 375 * ScreenWidth, y: 119.0 / 667 * ScreenHeight),
                radius: 89.0 / 375 * ScreenWidth, startAngle: CGFloat(3 * Double.pi / 2) ,
                endAngle: CGFloat(0), clockwise: true)
    path.addLine(to: CGPoint(x: 325.0 / 375 * ScreenWidth, y: 524))
    
    path.addArc(withCenter: CGPoint(x: 309.0 / 375 * ScreenWidth, y: 524.0 / 667 * ScreenHeight),
                radius: 16.0 / 375 * ScreenWidth, startAngle: CGFloat(0) ,
                endAngle: CGFloat(Double.pi / 2), clockwise: true)
    path.addLine(to: CGPoint(x: 66.0 / 375 * ScreenWidth, y: 540.0 / 667 * ScreenHeight))
    
    path.addArc(withCenter: CGPoint(x: 66.0 / 375 * ScreenWidth, y: 524.0 / 667 * ScreenHeight),
                radius: 16.0 / 375 * ScreenWidth, startAngle: CGFloat(Double.pi / 2) ,
                endAngle: CGFloat(Double.pi), clockwise: true)
    return path
  }
}

extension ViewController: CameraViewDelegate {
  func cameraView(_ cameraView: CameraView, predictionValue value: CGFloat, predictionImage image: UIImage) {
    _removePredicationViews()
    _updatePredicationViews(predicationValues: [predicationKey: value])
  }
  
  func cameraView(_ cameraView: CameraView, predicationValues values: [AnyHashable : Any], predictionImage image: UIImage) {
    _removePredicationViews()
    _updatePredicationViews(predicationValues: values)
  }
}

