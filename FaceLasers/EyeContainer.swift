import UIKit

class EyeContainer{
  
  // will store rectangles for Right and Left Eye
  public static let shared = EyeContainer()
  var leftEyes:[CGRect] = []
  
  var rightEyes:[CGRect] = []
  
  private init(){}
  
  public func addRightEye(eye:CGRect){
    rightEyes.append(eye)
  }
  
  public func addLeftEye(eye:CGRect){
    leftEyes.append(eye)
  }
  
}

