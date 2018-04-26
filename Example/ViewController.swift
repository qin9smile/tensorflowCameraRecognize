//
//  ViewController.swift
//  Example
//
//  Created by 宇宙超级无敌可爱美少女 on 2018/4/26.
//  Copyright © 2018年 宇宙超级无敌可爱美少女. All rights reserved.
//

import UIKit
import CameraRecognition

class ViewController: UIViewController {
  var cameraView: CameraView!
  var predicationViews: [UIView] = []
  var predicationKey: String = "yes"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cameraView = CameraView(frame: view.frame)
    cameraView.delegate = self
    cameraView.predicationKey = predicationKey
    //    cameraView.overlayPath = createBezierPath()
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

