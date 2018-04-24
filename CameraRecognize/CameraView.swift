//
//  CameraView.swift
//  tensorflowiOS
//
//  Created by charlotte on 2018/4/16.
//  Copyright © 2018年 gago. All rights reserved.
//

import UIKit
import AVFoundation

enum ScanDirection {
  case vertical
  case horizontal
}

// MARK: - Protocol

/// CameraViewDelegate
@objc
protocol CameraViewDelegate {

  /// CameraView
  ///
  /// - Parameters:
  ///   - cameraView: CameraView实例
  ///   - value: 本地图像识别的结果
  ///   - image: 用于本地图像识别的Image
  func cameraView(_ cameraView: CameraView, predictionValue value: CGFloat, predictionImage image: UIImage)
  
  @objc optional func cameraView(_ cameraView: CameraView, predicationValues values: [AnyHashable: Any], predictionImage image: UIImage)
}

// MARK: - CameraView

class CameraView: UIView {

  // MARK: - Public Properties

  /// 成像质量
  public var quality: AVCaptureSession.Preset = .medium {
    didSet {
      _captureSession.sessionPreset = quality
    }
  }

  public var isScanAnimationEnable: Bool = true {
    didSet {
      if isScanAnimationEnable {
        _addScanAnimation()
      } else {
        _removeScanAnimation()
      }
    }
  }

  /// 扫描线扫描方向
  public var scanAnimationDirection: ScanDirection = .vertical {
    didSet {
      _removeScanAnimation()
      scanNetAnimation.keyPath = _scanAnimationKeyPath
      _addScanAnimation()
    }
  }

  public var animationDuration:  CFTimeInterval = 3
  public var scanLineColor: UIColor = .blue {
    didSet {
      scanLineLayer?.backgroundColor = scanLineColor.cgColor
    }
  }
  private let scanNetAnimation = CABasicAnimation()

  private var _scanAnimationKeyPath: String {
    switch scanAnimationDirection {
    case .vertical: return "position.y"
    case .horizontal: return "position.x"
    }
  }
  
  /// 用于识别特定的Key
  public var predicationKey: String?

  /// 相机上显示的遮罩路径
  public var overlayPath: UIBezierPath? {
    didSet {
      guard let _overlayPath = overlayPath else {
        _clearLayout()
        return
      }

      _draw(_overlayPath)
    }
  }

  /// 相机上显示的遮罩颜色
  public var overlayFillColor: UIColor = UIColor.black.withAlphaComponent(0.4) {
    didSet {
      guard overlayPath != nil else { return }

      backgroundLayer.fillColor = overlayFillColor.cgColor
    }
  }

  /// 相机上显示的遮罩路径的颜色
  public var overlayStrokeColor: UIColor = UIColor.white {
    didSet {
      guard overlayPath != nil else { return }

      pathLayer.strokeColor = overlayStrokeColor.cgColor
    }
  }

  /// 相机上遮罩路径的lineWidth
  public var overlayLineWidth: CGFloat = 1 {
    didSet {
      guard overlayPath != nil else { return }

      pathLayer.lineWidth = overlayLineWidth
    }
  }

  /// 相机上遮罩路径的折角的样式
  public var overlayLineJoin: String = kCALineJoinMiter {
    didSet {
      guard overlayPath != nil else { return }

      pathLayer.lineJoin = overlayLineJoin
    }
  }

  /// 相机上遮罩路径的线段的开始或结束的样式
  public var overlayLineCap: String = kCALineCapSquare {
    didSet {
      guard overlayPath != nil else { return }

      pathLayer.lineCap = overlayLineCap
    }
  }

  /// 相机上遮罩路径的线段的实虚线的比例。
  public var overlayLineDashPattern: [NSNumber]? = [2, 4] {
    didSet {
      guard overlayPath != nil else { return }

      pathLayer.lineDashPattern = overlayLineDashPattern
    }
  }

  /// 置信度 -- 默认超过0.65认为识别正确
  public var predictionValue: CGFloat = 0.65

  /// 相机VideoOutpit的帧速率
  public var desiredRate: Int = 20

  /// Delegate
  public var delegate: CameraViewDelegate?

  // MARK: - Private Properties

  /// 设备相机权限
  private var _permission: Bool = false

  /// CaptureSession实例
  private let _captureSession = AVCaptureSession()

  /// CaptureSession执行的队列
  private let _sessionQueue = DispatchQueue(label: "session queue")

  /// 图像识别实例
  private let _imageRecognizer: ImageRecognizer = ImageRecognizer()

  /// 相机遮罩的路径Layer
  private var pathLayer: CAShapeLayer = CAShapeLayer()

  /// 相机遮罩的背景Layer
  private var backgroundLayer: CAShapeLayer = CAShapeLayer()

  private var maskScanLayer: CAShapeLayer?
  private var scanLineLayer: CAGradientLayer?

  // MARK: - Life Cycle

  override init(frame: CGRect) {
    super.init(frame: frame)
    _init()
  }

  convenience init() {
    self.init(frame: .zero)
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  private func _init() {
    _verifyPermission()
    _configureLayout()
    _sessionQueue.async {
      self._configureSession()
      self._configureTensorFlowModel(modelName: MODEL_FILE_NAME, labelName: LABEL_FILE_NAME)
      self._captureSession.startRunning()
    }
  }

}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate

extension CameraView: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    /// 获取ImageBuffer
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      debugPrint("the CMSampleBuffer does not contain a CVImageBuffer.")
      return
    }

    /// 识别
    _imageRecognizer.recognizer(imageBuffer)
  }
}

// MARK: - ImageRecognizerDelegate

extension CameraView: ImageRecognizerDelegate {
  /// 识别返回结果
  func imageRecognizer(_ predicationValue: [AnyHashable : Any]!, with pixelBuffer: CVPixelBuffer!) {
    let ciImage = CIImage(cvImageBuffer: pixelBuffer)
    let context = CIContext()
    guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent)  else {
      debugPrint("Creates a Quartz 2D image from a region of a Core Image image object failed.")
      return
    }

    DispatchQueue.main.async {
      let image = UIImage(cgImage: cgImage)
      self.delegate?.cameraView?(self, predicationValues: predicationValue, predictionImage: image)

      guard let _predicationKey = self.predicationKey,
        let value = predicationValue[_predicationKey] as? CGFloat else {
        return
      }

      if value > self.predictionValue {
        /// 识别结果正确
        self.delegate?.cameraView(self, predictionValue: value, predictionImage: image)
      }
    }
  }
}

// MARK: - Private Methods

extension CameraView {

  // MARK: Configure Camera Session and I/O

  /// 验证设备权限
  private func _verifyPermission() {
    switch AVCaptureDevice.authorizationStatus(for: .video) {
    case .authorized:
      _permission = true
    case .notDetermined:
      _requestPermission()
    default:
      _permission = false
    }
  }

  /// 请求设备权限
  private func _requestPermission() {
    _sessionQueue.suspend()
    AVCaptureDevice.requestAccess(for: .video) { permission in
      self._permission = permission
      self._sessionQueue.resume()
    }
  }

  /// 配置Session
  private func _configureSession() {
    guard _permission else {
      debugPrint("device has not permission.")
      return
    }

    /// 配置session preset
    _captureSession.sessionPreset = quality
    /// 获取CaptureDevice
    guard let captureDevice = AVCaptureDevice.default(for: .video) else {
      debugPrint("get instance of AVCaptureDevice failed")
      return
    }

    /// 获取DeviceInput
    guard let captureDeviceInput = try? AVCaptureDeviceInput(device: captureDevice) else {
      debugPrint("the device could not be used for capture.")
      return
    }

    guard _captureSession.canAddInput(captureDeviceInput) else {
      debugPrint("capture cannot add input.")
      return
    }

    _captureSession.addInput(captureDeviceInput)

    /// 配置Device的帧速率
    do {
      try captureDevice.lockForConfiguration()
      let format = captureDevice.activeFormat

      for range in format.videoSupportedFrameRateRanges {
        if range.maxFrameRate >= Float64(desiredRate) && range.minFrameRate <= Float64(desiredRate) {
          captureDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: CMTimeScale(desiredRate))
          captureDevice.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: CMTimeScale(desiredRate))
        }
      }

      captureDevice.unlockForConfiguration()
    } catch {
      debugPrint("the device could not be locked.")
    }

    /// 添加VideoOutput
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer queue"))
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey: kCMPixelFormat_32BGRA] as [String: Any]
    guard _captureSession.canAddOutput(videoOutput) else {
      debugPrint("capture cannot add output.")
      return
    }

    _captureSession.addOutput(videoOutput)
  }

  // MARK: - Configure Tensorflow

  /// 加载本地TensorFlow模型
  private func _configureTensorFlowModel(modelName: String, labelName: String) {
    _imageRecognizer.delegate = self
    _imageRecognizer.loadModel(modelName, withLabelFileName: labelName)
  }

  // MARK: - Configure Layout

  /// 配置Camera Preview 及layout layer
  private func _configureLayout() {
    let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: _captureSession)
    videoPreviewLayer.videoGravity = .resizeAspectFill
    videoPreviewLayer.frame = CGRect(origin: .zero, size: frame.size)
    layer.addSublayer(videoPreviewLayer)

    backgroundLayer.frame = CGRect(origin: .zero, size: frame.size)
    layer.addSublayer(backgroundLayer)
    pathLayer.frame = CGRect(origin: .zero, size: frame.size)
    layer.addSublayer(pathLayer)

    if isScanAnimationEnable {
      _addScanAnimation()
    }
  }

  /// 绘制基于传入的贝塞尔曲线的遮罩
  ///
  /// - Parameter overlayPath: 遮罩路径
  private func _draw(_ overlayPath: UIBezierPath) {
    // 形状
    pathLayer.lineWidth = overlayLineWidth
    pathLayer.lineJoin = overlayLineJoin
    pathLayer.lineCap = overlayLineCap
    //虚线
    pathLayer.lineDashPattern = overlayLineDashPattern
    //路径颜色
    pathLayer.strokeColor = overlayStrokeColor.cgColor
    pathLayer.path = overlayPath.cgPath
    pathLayer.fillColor = UIColor.clear.cgColor

    // 猪的形状遮罩
    let _overlayPath = UIBezierPath(rect: CGRect(origin: .zero, size: frame.size))
    _overlayPath.append(overlayPath)
    _overlayPath.usesEvenOddFillRule = true

    // 半透明背景遮罩
    backgroundLayer.fillColor = overlayFillColor.cgColor

    backgroundLayer.path = _overlayPath.cgPath
    backgroundLayer.fillRule = kCAFillRuleEvenOdd//超出的部分填充颜色

    if isScanAnimationEnable {
      _addScanAnimation()
    } else {
      _removeScanAnimation()
    }
  }

  /// 清除所有的Layer样式
  private func _clearLayout() {
    backgroundLayer.path = nil
    pathLayer.path = nil
    _removeScanAnimation()
  }

  // MARK: - Scan Animation

  private func _addScanAnimation() {
    guard let _overlayPath = overlayPath else {
      return
    }

    _removeScanAnimation()

    let _maskScanLayer = CAShapeLayer()
    _maskScanLayer.frame = CGRect(origin: .zero, size: frame.size)
    _maskScanLayer.fillColor = UIColor.clear.cgColor
    _maskScanLayer.borderWidth = 3
    self.maskScanLayer = _maskScanLayer

    /// 线
    let _scanLineLayer = CAGradientLayer()

    _scanLineLayer.locations = [0, 0.1, 0.5, 0.9, 1]
    _scanLineLayer.shadowColor = UIColor(hue: 211.0 / 360.0, saturation: 1, brightness: 75.0 / 100.0, alpha: 0.5).cgColor
    _scanLineLayer.shadowOffset = CGSize.zero
    _scanLineLayer.shadowRadius = 2
    _scanLineLayer.shadowOpacity = 0.5

    _scanLineLayer.colors = [
      UIColor(hue: 211.0 / 360.0, saturation: 1, brightness: 75.0 / 100.0, alpha: 0).cgColor,
      UIColor(hue: 211.0 / 360.0, saturation: 1, brightness: 75.0 / 100.0, alpha: 1).cgColor,
      UIColor(hue: 211.0 / 360.0, saturation: 70.0 / 100.0, brightness: 1, alpha: 1).cgColor,
      UIColor(hue: 211.0 / 360.0, saturation: 1, brightness: 75.0 / 100.0, alpha: 1).cgColor,
      UIColor(hue: 211.0 / 360.0, saturation: 1, brightness: 75.0 / 100.0, alpha: 0).cgColor
    ]

    _maskScanLayer.addSublayer(_scanLineLayer)
    self.scanLineLayer = _scanLineLayer

    let maskLayer = CAShapeLayer()
    maskLayer.frame = CGRect(origin: .zero, size: frame.size)

    maskLayer.path = _overlayPath.cgPath
    maskLayer.fillRule = kCAFillRuleEvenOdd
    _maskScanLayer.mask = maskLayer
    layer.addSublayer(_maskScanLayer)

    scanNetAnimation.keyPath = _scanAnimationKeyPath

    if scanAnimationDirection == .vertical {
      scanNetAnimation.fromValue = 0
      scanNetAnimation.toValue = _overlayPath.bounds.size.height

      _scanLineLayer.frame = CGRect(origin: CGPoint(x: _overlayPath.bounds.minX,
                                                    y: _overlayPath.bounds.minY),
                                    size: CGSize(width: _overlayPath.bounds.size.width,
                                                 height: 3))
      _scanLineLayer.locations = [0, 0.1, 0.5, 0.9, 1]
      _scanLineLayer.startPoint = CGPoint(x: 0, y: 0.5)
      _scanLineLayer.endPoint = CGPoint(x: 1, y: 0.5)
    } else {
      scanNetAnimation.fromValue = _overlayPath.bounds.maxX
      scanNetAnimation.toValue = _overlayPath.bounds.minX

      _scanLineLayer.frame = CGRect(origin: CGPoint(x: _overlayPath.bounds.maxX,
                                                    y: _overlayPath.bounds.minY),
                                    size: CGSize(width: 3,
                                                 height: _overlayPath.bounds.size.height))
      _scanLineLayer.locations = [0, 0.1, 0.5, 0.9, 1]
      _scanLineLayer.startPoint = CGPoint(x: 0.5, y: 0)
      _scanLineLayer.endPoint = CGPoint(x: 0.5, y: 1)
    }

    scanNetAnimation.duration = animationDuration
    scanNetAnimation.fillMode = kCAFillModeForwards
    scanNetAnimation.autoreverses = true

    let animationGroup = CAAnimationGroup()
    animationGroup.animations = [scanNetAnimation]
    animationGroup.duration = animationDuration
    animationGroup.repeatCount = .greatestFiniteMagnitude
    _scanLineLayer.add(animationGroup, forKey: "scan line")
  }

  private func _removeScanAnimation() {
    maskScanLayer?.removeFromSuperlayer()
    scanLineLayer?.removeFromSuperlayer()
    scanLineLayer?.removeAnimation(forKey: "scan line")
  }
}
