//
//  ViewController.swift
//  CameraRecognize
//
//  Created by 宇宙超级无敌可爱美少女 on 2018/4/23.
//  Copyright © 2018年 宇宙超级无敌可爱美少女. All rights reserved.
//

import UIKit
let MODEL_FILE_NAME: String = "tensorflow_inception_graph"
let LABEL_FILE_NAME: String = "imagenet_comp_graph_label_strings"

class ViewController: UIViewController {
  var predicateLabel: UILabel!
  var cameraView: CameraView!
  override func viewDidLoad() {
    super.viewDidLoad()
    
    cameraView = CameraView(frame: view.frame)
    cameraView.delegate = self
//    cameraView.overlayPath = createBezierPath()
    cameraView.scanAnimationDirection = .horizontal
    view.addSubview(cameraView)
    
    predicateLabel = UILabel(frame: CGRect(x: 20, y: 70, width: 300, height: 30))
    predicateLabel.textColor = .white
    predicateLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
    predicateLabel.text = "识别率："
    view.addSubview(predicateLabel)
  }
}

extension ViewController: CameraViewDelegate {
  func cameraView(_ cameraView: CameraView, predictionValue value: CGFloat, predictionImage image: UIImage) {
    predicateLabel.text = String(format: "识别率: %.4f", value)
  }
}
