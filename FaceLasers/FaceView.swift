import UIKit
import Vision
import CoreGraphics

class FaceView: UIView {
  var leftEye: [CGPoint] = []
  var rightEye: [CGPoint] = []
  var leftEyebrow: [CGPoint] = []
  var rightEyebrow: [CGPoint] = []
  var nose: [CGPoint] = []
  var outerLips: [CGPoint] = []
  var innerLips: [CGPoint] = []
  var faceContour: [CGPoint] = []

  var boundingBox = CGRect.zero
  
  func clear() {
    leftEye = []
    rightEye = []
    leftEyebrow = []
    rightEyebrow = []
    nose = []
    outerLips = []
    innerLips = []
    faceContour = []
    
    boundingBox = .zero
    
    DispatchQueue.main.async {
      self.setNeedsDisplay()
    }
  }
  
  override func draw(_ rect: CGRect) {
    
    //print(rect)
    
    // 1
    guard let context = UIGraphicsGetCurrentContext() else {
      return
    }

    // 2
    context.saveGState()

    // 3
    defer {
      context.restoreGState()
    }

    // 4
    context.addRect(boundingBox)

    // 5
    UIColor.red.setStroke()

    // 6
    context.strokePath()

    // 1
    UIColor.white.setStroke()

    
    
    ///Left Eye
    if !leftEye.isEmpty {
//      // 2
//      context.addLines(between: leftEye)
//
//      // 3
//      context.closePath()
//
//      // 4
//      context.strokePath()
//
      // down left point
      // top left point
      // top right point
      // down right point
      //let point = CGPoint(x: 0, y: 0)
            
      let topMostPoint = leftEye.max { point1, point2 in
        return point1.y < point2.y
      }
      
      let bottomMostPoint = leftEye.max { point1, point2 in
        return point1.y > point2.y
      }
      
      let leftMostPoint = leftEye.max { point1, point2 in
        return point1.x > point2.x
      }
      
      let rightMostPoint = leftEye.max { point1, point2 in
        return point1.x < point2.x
      }
      
      // Make rectangle
      
      let point1: CGPoint = CGPoint(x: leftMostPoint!.x, y: topMostPoint!.y)
      let point2: CGPoint = CGPoint(x: leftMostPoint!.x, y: bottomMostPoint!.y)
      let point3: CGPoint = CGPoint(x: rightMostPoint!.x, y: bottomMostPoint!.y)
      let point4: CGPoint = CGPoint(x: rightMostPoint!.x, y: topMostPoint!.y)
      
      let rectangle = CGRect(x: point1.x, y: point1.y, width: point4.x-point1.x, height:point1.y-point2.y)
      //print("Left eye rect: \(rectangle)")
      
      if EyeProcessor.shared.shouldStoreFlag {
        EyeProcessor.shared.leftEyeRectangles.append(rectangle)
      }
      
      EyeContainer.shared.addLeftEye(eye: rectangle)
      
      
      
      context.addLines(between: [point1, point2, point3, point4])
      context.closePath()
      context.strokePath()
      
    }

    //Right Eye
    if !rightEye.isEmpty {
      // down left point
      // top left point
      // top right point
      // down right point
      //let point = CGPoint(x: 0, y: 0)
      
      let topMostPoint = rightEye.max { point1, point2 in
        return point1.y < point2.y
      }
      
      let bottomMostPoint = rightEye.max { point1, point2 in
        return point1.y > point2.y
      }
      
      let leftMostPoint = rightEye.max { point1, point2 in
        return point1.x > point2.x
      }
      
      let rightMostPoint = rightEye.max { point1, point2 in
        return point1.x < point2.x
      }
      
      // Make rectangle
      
      let point1: CGPoint = CGPoint(x: leftMostPoint!.x, y: topMostPoint!.y)
      let point2: CGPoint = CGPoint(x: leftMostPoint!.x, y: bottomMostPoint!.y)
      let point3: CGPoint = CGPoint(x: rightMostPoint!.x, y: bottomMostPoint!.y)
      let point4: CGPoint = CGPoint(x: rightMostPoint!.x, y: topMostPoint!.y)
      
      let rectangle = CGRect(x: point1.x, y: point1.y, width: point4.x-point1.x, height:point1.y-point2.y)
     // print(rectangle)
      EyeContainer.shared.addRightEye(eye: rectangle)
//      let rectangle = CGRect(x: <#T##CGFloat#>, y: <#T##CGFloat#>, width: <#T##CGFloat#>, height: <#T##CGFloat#>)
      
      //od EyeContainer
      // 1. Slika od kvadratceto "points"
        //  UIImage od CGRect
        //  Save na device
      // 2. Extract na pixeli vo csv format (id,x,y,r,g,b,a)
      // 3. Da se stavat vo tabular data za CreateML model
      // 3. 100 Sliki da gi zacuvame na device i da se napravi tabular data
      // 4. Training na data setot
      
      context.addLines(between: [point1, point2, point3, point4])
      
      context.closePath()
      context.strokePath()
      
      
    }
    
    

    if !leftEyebrow.isEmpty {
      context.addLines(between: leftEyebrow)
      context.strokePath()
    }

    if !rightEyebrow.isEmpty {
      context.addLines(between: rightEyebrow)
      context.strokePath()
    }

    if !nose.isEmpty {
      context.addLines(between: nose)
      context.strokePath()
    }

    if !outerLips.isEmpty {
      context.addLines(between: outerLips)
      context.closePath()
      context.strokePath()
    }

    if !innerLips.isEmpty {
      context.addLines(between: innerLips)
      context.closePath()
      context.strokePath()
    }

    if !faceContour.isEmpty {
      context.addLines(between: faceContour)
      context.strokePath()
    }
  }
  
  // Convert CIImage to UIImage
  func convert(cmage: CIImage) -> UIImage {
       let context = CIContext(options: nil)
       let cgImage = context.createCGImage(cmage, from: cmage.extent)!
       let image = UIImage(cgImage: cgImage)
       return image
  }
  
}
