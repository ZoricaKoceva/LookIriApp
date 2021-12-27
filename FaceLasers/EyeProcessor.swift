import CoreImage
import Vision
import UIKit
import AVFoundation
//import coremltools
//from coremltools.models.neural_network import SgdParams

public class EyeProcessor {
  
  var sequenceHandler = VNSequenceRequestHandler()
  var shouldStoreFlag: Bool = false
  var currentImageBuffer: CVImageBuffer!
  var currentSampleBuffer: CMSampleBuffer!
  var currentImage: CIImage!
  var previewLayer: AVCaptureVideoPreviewLayer!
  var imageBufferStorage: [CVImageBuffer] = [CVImageBuffer]()
  var imageBuffer: [UIImage] = [UIImage]()
  var leftEyeRectangles: [CGRect] = [CGRect]()
  var rightEyeRectangles: [CGRect]?
  
  private init() {}
  
  public static var shared = EyeProcessor()
  
//  public var dataTable: MLDataTable?
    
  func detectedFace(request: VNRequest, error: Error?) {
    guard let results = request.results as? [VNFaceObservation], let result = results.first else {
      return
    }

    let leftEyePoints = landmark(points: result.landmarks?.leftEye?.normalizedPoints, to: result.boundingBox)
    let leftEyeRect = RectangleMaker.fromPoints(points: leftEyePoints!).offsetBy(dx: 8, dy: -12)
    print(leftEyeRect)
    
    guard let image = Helper.getImageFromSampleBuffer(sampleBuffer: currentSampleBuffer) else {
      return
    }
    
    let model = TabularDClassifierLeftEye()
    let imageDataArray = processImage(image: image)
//    print(imageDataArray)
    for pixelData in imageDataArray!{
      print(pixelData.x, pixelData.y, pixelData.r, pixelData.g, pixelData.b, pixelData.alpha);
      let resultData = try? model.prediction(
                            x: Double(imageDataArray!.first!.x),
                            y: Double(imageDataArray!.first!.y),
                            r: Double(imageDataArray!.first!.r),
                            g: Double(imageDataArray!.first!.g),
                            b: Double(imageDataArray!.first!.b),
                            alpha: Double(imageDataArray!.first!.alpha))
      print(resultData?.Photo)
      print(resultData?.PhotoProbability)

    }
    
    
    
    // Next steps:
    
    // 1. Create Updatable model (da se proveri dali mozi da imame updatable tabular data model ?)
    

//
//    output_labels = ["Left", "Right"]
//    coreml_model = coremltools.converters.keras.convert("model.h5", input_names=["image"], output_names=["output"],
//                                                       class_labels=output_labels,
//                                                       image_input_names="image")
//
//    coreml_model.author = "Zorica"
//    coreml_model.short_description = "Left and Right Eye to a model"
//    coreml_model.input_description["image"] = "Takes as input an image"
//    coreml_model.output_description["output"] = "Prediction as left or right eye"
//    coreml_model.output_description["classLabel"] = "Returns Left Or Right as class label"
//
//    coreml_model_path = "./catdogclassifier.mlmodel"
//
//    spec = coremltools.utils.load_spec(coreml_model_path)
//    builder = coremltools.models.neural_network.NeuralNetworkBuilder(spec=spec)
//    builder.inspect_layers(last=3)
//    builder.inspect_input_features()
//
//    coreml_model.save("catdogclassifier.mlmodel")
//
//
//    model_spec = builder.spec
//    builder.make_updatable(["dense_5", "dense_6"])
//    builder.set_categorical_cross_entropy_loss(name="lossLayer", input="output")
//
//
//    builder.set_sgd_optimizer(SgdParams(lr=0.01, batch=5))
//    builder.set_epochs(2)
//
//    coremltools.utils.save_spec(model_spec, "LeftRightEyesUpdatable.mlmodel")
//
//
//    let csvFile = Bundle.main.url(forResource: "EyeProcessor", withExtension: "csv")!
//    let dataTable = try MLDataTable(contentsOf: csvFile)
    // 2. Watch https://developer.apple.com/videos/play/wwdc2019/704/ see model personalization
    // 3. Check if isUpdatable flag is available when training the TabularData model (check in CreateML)
    // 4. Check for relevant info https://betterprogramming.pub/how-to-create-updatable-models-using-core-ml-3-cc7decd517d5
    //  https://betterprogramming.pub/how-to-train-a-core-ml-model-on-your-device-cccd0bee19d
    // 5. Import TabularData model into the app.
    
    
    
    //  Not needed, MLClassifier is only available in Swift Playground.
    
//
//    let dict: [String : MLDataValueConvertible] = [
//      "id": [1,2,3],
//      "photo": ["slika1", "slika2", "slika3"],
//      "x": [1,2,3],
//      "y": [1,2,3],
//      "r": [1,2,3],
//      "g": [1,2,3],
//      "b": [1,2,3],
//      "alpha": [1,2,3]
//    ]
//
//    dataTable = try? MLDataTable(dictionary: dict)
//    let regressorColumns = ["id", "x", "y", "r", "g", "b", "alpha"]
//    let regressorTable = dataTable![regressorColumns]
//
//    let classifierColumns = ["photo", "x", "y", "r", "g", "b", "alpha"]
//    let classifierTable = dataTable![classifierColumns]
//
//    let (regressorEvaluationTable, regressorTrainingTable) = regressorTable.randomSplit(by: 0.20, seed: 5)
//    let (classifierEvaluationTable, classifierTrainingTable) = classifierTable.randomSplit(by: 0.20, seed: 5)
//
//    let regressor = try! MLLinearRegressor(trainingData: regressorTrainingTable,
//                                           targetColumn: "id")
//    /// The largest distances between predictions and the expected values
//    let worstTrainingError = regressor.trainingMetrics.maximumError
//    let worstValidationError = regressor.validationMetrics.maximumError
//
//    /// Evaluate the regressor
//    let regressorEvalutation = regressor.evaluation(on: regressorEvaluationTable)
//
//    /// The largest distance between predictions and the expected values
//    let worstEvaluationError = regressorEvalutation.maximumError
//
//
//    let classifier = try! MLClassifier(trainingData: classifierTrainingTable,
//                                       targetColumn: "photo")
//
//
    
    
    
    
    
    let box = convert(rect: result.boundingBox)
    print("Bounding box: \(box)")
    
    let screenSize = UIScreen.main.bounds.size
    //let screenSize = CGSize(width: 375.0, height: 667.0)
    print("Screen size: \(screenSize)")
    print("Preview layer frame: \(previewLayer.frame)")
    
    let resizedImage = image.resizeImage(image: image, targetSize: screenSize)
    print("Resized image size: \(resizedImage?.size)")
    
    let newImage = drawOnImage(resizedImage!, rect: leftEyeRect)
    let newImage1 = drawOnImage(newImage, rect: CGRect(x: 0, y: 0, width: newImage.size.width, height: newImage.size.height))
    let newImage2 = drawOnImage(newImage1, rect: box)
    
    let croppedImage = cropImage(resizedImage!,
                                 toRect:leftEyeRect,
                                 viewWidth: screenSize.width,
                                 viewHeight: screenSize.height)
    
    UIImageWriteToSavedPhotosAlbum(newImage2, nil, nil, nil)
    UIImageWriteToSavedPhotosAlbum(croppedImage!, nil, nil, nil)
    
    
//    let testImage = image.resize(to: CGSize(width: 10, height: 10))
//    UIImageWriteToSavedPhotosAlbum(testImage!, nil, nil, nil)
    
  }
  
  func processDetection(with imageBuffer: CVImageBuffer,
                        sampleBuffer: CMSampleBuffer,
                        image: CIImage) {
    currentImageBuffer = imageBuffer
    currentSampleBuffer = sampleBuffer
    currentImage = image
    let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
    if #available(iOS 13.0, *) {
      detectFaceRequest.constellation = .constellation76Points
    } else {
      // Fallback on earlier versions
    }
    
    do {
      //try sequenceHandler.perform([detectFaceRequest], on: imageBuffer, orientation: .leftMirrored)
      try sequenceHandler.perform([detectFaceRequest], on: image, orientation: .leftMirrored)
    } catch {
      print(error.localizedDescription)
    }
  }
  
  func convert(rect: CGRect) -> CGRect {
    let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)
    let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)
    return CGRect(origin: origin, size: size.cgSize)
  }

  
  func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
    guard let points = points else {
      return nil
    }
    
    return points.compactMap {
      landmark(point: $0, to: rect)
    }
  }
  
  func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
    let absolute = point.absolutePoint(in: rect)
    let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)
    return converted
  }
    
  func drawOnImage(_ image: UIImage, rect: CGRect) -> UIImage {
       
       // Create a context of the starting image size and set it as the current one
       UIGraphicsBeginImageContext(image.size)
       
       // Draw the starting image in the current context as background
       image.draw(at: CGPoint.zero)

       // Get the current context
       let context = UIGraphicsGetCurrentContext()!

       // Draw a red line
       context.setLineWidth(2.0)
       context.setStrokeColor(UIColor.red.cgColor)
       context.addRect(rect)
       context.strokePath()
       
       
       // Save the context as a new UIImage
       let myImage = UIGraphicsGetImageFromCurrentImageContext()
       UIGraphicsEndImageContext()
       
       // Return modified image
       return myImage!
  }
  
  
  
  func cropImage(_ inputImage: UIImage, toRect cropRect: CGRect, viewWidth: CGFloat, viewHeight: CGFloat) -> UIImage? {
      let imageViewScale = max(inputImage.size.width / viewWidth,
                               inputImage.size.height / viewHeight)

      // Scale cropRect to handle images larger than shown-on-screen size
      let cropZone = CGRect(x:cropRect.origin.x * imageViewScale,
                            y:cropRect.origin.y * imageViewScale,
                            width:cropRect.size.width * imageViewScale,
                            height:cropRect.size.height * imageViewScale)

      // Perform cropping in Core Graphics
      guard let cutImageRef: CGImage = inputImage.cgImage?.cropping(to: cropZone)
      else {
          return nil
      }

      // Return image to UIImage
      let croppedImage: UIImage = UIImage(cgImage: cutImageRef)
      return croppedImage
  }
}



extension UIImage {
  
  func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
      let size = image.size
      
      let widthRatio  = targetSize.width  / size.width
      let heightRatio = targetSize.height / size.height
      
      // Figure out what our orientation is, and use that to form the rectangle
      var newSize: CGSize
      if(widthRatio > heightRatio) {
          newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
      } else {
          newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
      }
      
      // This is the rect that we've calculated out and this is what is actually used below
      let rect = CGRect(origin: .zero, size: targetSize)
      
      // Actually do the resizing to the rect using the ImageContext stuff
      UIGraphicsBeginImageContextWithOptions(targetSize, false, 1.0)
      image.draw(in: rect)
      let newImage = UIGraphicsGetImageFromCurrentImageContext()
      UIGraphicsEndImageContext()
      
      return newImage
  }

}
