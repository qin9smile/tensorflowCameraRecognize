//
//  UIBezierPath+.swift
//  CameraRecognition
//
//  Created by 宇宙超级无敌可爱美少女 on 2018/4/27.
//  Copyright © 2018年 宇宙超级无敌可爱美少女. All rights reserved.
//

// https://github.com/xhamr/paintcode-path-scale/blob/master/UIBezierPath%2B.swift
import UIKit

extension CGRect{
  var center: CGPoint {
    return CGPoint( x: self.size.width/2.0,y: self.size.height/2.0)
  }
}
extension CGPoint{
  func vector(to p1:CGPoint) -> CGVector{
    return CGVector(dx: p1.x-self.x, dy: p1.y-self.y)
  }
}

extension UIBezierPath{
  func moveCenter(to:CGPoint) -> Self {
    let bound  = self.cgPath.boundingBox
    let center = bounds.center
    let zeroedTo = CGPoint(x: to.x-bound.origin.x, y: to.y-bound.origin.y)
    let vector = center.vector(to: zeroedTo)
    return offset(to: CGSize(width: vector.dx, height: vector.dy))
  }
  
  func offset(to offset:CGSize) -> Self{
    let t = CGAffineTransform(translationX: offset.width, y: offset.height)
    return applyCentered(transform: t)
  }
  
  func fit(into:CGRect) -> Self{
    let bounds = self.cgPath.boundingBox
    let sw     = into.size.width/bounds.width
    let sh     = into.size.height/bounds.height
    let factor = min(sw, max(sh, 0.0))
    return scale(x: factor, y: factor)
  }
  
  func scale(x:CGFloat, y:CGFloat) -> Self{
    let scale = CGAffineTransform(scaleX: x, y: y)
    return applyCentered(transform: scale)
  }
  
  func applyCentered(transform: @autoclosure () -> CGAffineTransform ) -> Self{
    let bound  = self.cgPath.boundingBox
    let center = CGPoint(x: bound.midX, y: bound.midY)
    var xform  = CGAffineTransform.identity
    
    xform = xform.concatenating(CGAffineTransform(translationX: -center.x, y: -center.y))
    xform = xform.concatenating(transform())
    xform = xform.concatenating( CGAffineTransform(translationX: center.x, y: center.y))
    apply(xform)
    return self
  }
}
