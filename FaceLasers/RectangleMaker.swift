import UIKit

public struct RectangleMaker {
  
  static func fromPoints(points: [CGPoint]) -> CGRect {
    let topMostPoint = points.max { point1, point2 in
      return point1.y < point2.y
    }
    
    let bottomMostPoint = points.max { point1, point2 in
      return point1.y > point2.y
    }
    
    let leftMostPoint = points.max { point1, point2 in
      return point1.x > point2.x
    }
    
    let rightMostPoint = points.max { point1, point2 in
      return point1.x < point2.x
    }
    
    // Make rectangle
    
    let point1: CGPoint = CGPoint(x: leftMostPoint!.x, y: topMostPoint!.y)
    let point2: CGPoint = CGPoint(x: leftMostPoint!.x, y: bottomMostPoint!.y)
    let point3: CGPoint = CGPoint(x: rightMostPoint!.x, y: bottomMostPoint!.y)
    let point4: CGPoint = CGPoint(x: rightMostPoint!.x, y: topMostPoint!.y)
    
    return CGRect(x: point1.x, y: point1.y, width: point4.x-point1.x, height:point1.y-point2.y)
    
    
  }
  
}
