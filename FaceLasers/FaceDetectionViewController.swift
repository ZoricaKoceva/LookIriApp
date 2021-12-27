import AVFoundation
import UIKit
import Vision
import CoreML


class FaceDetectionViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
  var sequenceHandler = VNSequenceRequestHandler()

  @IBOutlet var faceView: FaceView! {
    didSet {
      print(faceView.bounds)
    }
  }
  @IBOutlet var laserView: LaserView!
  @IBOutlet var faceLaserLabel: UILabel!
  
  var cameraImageBuffer: [CVImageBuffer] = []
  var cameraImageSampleBuffer: [UIImage?] = []
  var shouldStoreInBufferStorage: Bool = false
  
  public func handleImageBuffer(buffer: CVImageBuffer, completion: @escaping ()->Void ) {
    DispatchQueue.global().async {
      self.cameraImageBuffer.append(buffer)
      completion()
    }
  }
  
  @IBAction func startPressed(_ sender: Any) {
    shouldStoreInBufferStorage = true
    EyeProcessor.shared.shouldStoreFlag = true
  }
  
  @IBAction func stopPressed(_ sender: Any) {
    shouldStoreInBufferStorage = false
    EyeProcessor.shared.shouldStoreFlag = false    
    
  }
  
  func processImages(images: [UIImage?]) {
    
  }
  
  func setUpModel(){
    let model = TabularDClassifierLeftEye()
  }
  
  let session = AVCaptureSession()
  var previewLayer: AVCaptureVideoPreviewLayer!
  
  let dataOutputQueue = DispatchQueue(
    label: "video data queue",
    qos: .userInitiated,
    attributes: [],
    autoreleaseFrequency: .workItem)

  var faceViewHidden = false
  
  var maxX: CGFloat = 0.0
  var midY: CGFloat = 0.0
  var maxY: CGFloat = 0.0

  override func viewDidLoad() {
    super.viewDidLoad()
    configureCaptureSession()
    
    laserView.isHidden = true
    
    maxX = view.bounds.maxX
    midY = view.bounds.midY
    maxY = view.bounds.maxY
    
    session.startRunning()
  }
  
}

// MARK: - Gesture methods

extension FaceDetectionViewController {
  @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
    faceView.isHidden.toggle()
    laserView.isHidden.toggle()
    faceViewHidden = faceView.isHidden
    
    if faceViewHidden {
      faceLaserLabel.text = "Lasers"
    } else {
      faceLaserLabel.text = "Face"
    }
  }
}

// MARK: - Video Processing methods

extension FaceDetectionViewController {
  func configureCaptureSession() {
    // Define the capture device we want to use
    guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera,
                                               for: .video,
                                               position: .front) else {
      fatalError("No front video camera available")
    }
    
    // Connect the camera to the capture session input
    do {
      let cameraInput = try AVCaptureDeviceInput(device: camera)
      session.addInput(cameraInput)
    } catch {
      fatalError(error.localizedDescription)
    }
    
    // Create the video data output
    let videoOutput = AVCaptureVideoDataOutput()
    videoOutput.setSampleBufferDelegate(self, queue: dataOutputQueue)
    videoOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA]
    
    // Add the video output to the capture session
    session.addOutput(videoOutput)
    
    let videoConnection = videoOutput.connection(with: .video)
    videoConnection?.videoOrientation = .portrait
    
    // Configure the preview layer
    previewLayer = AVCaptureVideoPreviewLayer(session: session)
    previewLayer.videoGravity = .resizeAspectFill
    previewLayer.frame = view.bounds
    view.layer.insertSublayer(previewLayer, at: 0)
  }
}

// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate methods

extension FaceDetectionViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
  func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
    // 1
    guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
      return
    }
    
    let uiImage = Helper.getImageFromSampleBuffer(sampleBuffer: sampleBuffer)!
    
    if shouldStoreInBufferStorage {
      
      EyeProcessor.shared.previewLayer = previewLayer
      EyeProcessor.shared.processDetection(with: imageBuffer,
                                           sampleBuffer: sampleBuffer,
                                           image: CIImage(cvImageBuffer: imageBuffer))
      shouldStoreInBufferStorage = false
      
      
//      guard let image = getImageFromSampleBuffer(sampleBuffer: sampleBuffer) else {
//        return
//      }
//
//      EyeProcessor.shared.imageBufferStorage.append(imageBuffer)
//
//      let color = image.pixelColor(x: 0, y: 0)
      
      /*
      // 1. width: 1000 x  height: 400 -> resize na fiksen (hight = 100) -> height: 100 width: 300?
      // 2. Funkcijata za printanje
      
      
      // funkcija x i y na slikata
      // primer slika 200 x 200
       
      color za piksel 0 x 0
      color za piksel 0 x 1
      color za piksel 0 x 2
      color za piksel 0 x 3
      color za piksel 0 x ..200
      
      color za piksel 1 x 0
      color za piksel 1 x 1
      color za piksel 1 x 2
      color za piksel 1 x ..200
      
      // dva for ciklusi
      
      // for
      //    for
      //          print
      
      // pecati na
      
      */
      

//      cameraImageSampleBuffer.append(image)
    }
    
    // 2
    let detectFaceRequest = VNDetectFaceLandmarksRequest(completionHandler: detectedFace)
    // Changes
    if #available(iOS 13.0, *) {
      detectFaceRequest.constellation = .constellation76Points
    } else {
      // Fallback on earlier versions
    }
    
    // 3
    do {
      try sequenceHandler.perform([detectFaceRequest], on: imageBuffer, orientation: .leftMirrored)
    } catch {
      print(error.localizedDescription)
    }
  }
}


extension FaceDetectionViewController {
  func convert(rect: CGRect) -> CGRect {
    // 1
    let origin = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.origin)

    // 2
    let size = previewLayer.layerPointConverted(fromCaptureDevicePoint: rect.size.cgPoint)

    // 3
    return CGRect(origin: origin, size: size.cgSize)
  }

  // 1
  func landmark(point: CGPoint, to rect: CGRect) -> CGPoint {
    // 2
    let absolute = point.absolutePoint(in: rect)

    // 3
    let converted = previewLayer.layerPointConverted(fromCaptureDevicePoint: absolute)

    // 4
    return converted
  }

  func landmark(points: [CGPoint]?, to rect: CGRect) -> [CGPoint]? {
    guard let points = points else {
      return nil
    }

    return points.compactMap { landmark(point: $0, to: rect) }
  }
  
  func updateFaceView(for result: VNFaceObservation) {
    defer {
      DispatchQueue.main.async { [self] in
        self.faceView.setNeedsDisplay()
        //print("Face view frame: \(self.faceView.frame)")
        //print("Preview layer frame: \(self.previewLayer.frame)")
        
        
        
      }
    }

    let box = result.boundingBox
    faceView.boundingBox = convert(rect: box)
    //print("Bounding box: \(faceView.boundingBox)")
    

    guard let landmarks = result.landmarks else {
      return
    }
    

    if let leftEye = landmark(points: landmarks.leftEye?.normalizedPoints,
                              to: result.boundingBox) {
      faceView.leftEye = leftEye
    }

    if let rightEye = landmark(points: landmarks.rightEye?.normalizedPoints,
                               to: result.boundingBox) {
      faceView.rightEye = rightEye
    }
    
    //rectangles for detecting eyes
              //    let rectangle = UIBezierPath.init()
              //    let width = UIScreen.main.bounds.size.width
              //    let height = UIScreen.main.bounds.size.height
              //
              //    rectangle.move(to: CGPoint.init(x: width, y: height))
              //
              //    rectangle.addLine(to: CGPoint.init(x: width, y: height))
              //    rectangle.addLine(to: CGPoint.init(x: width, y: height))
              //    rectangle.addLine(to: CGPoint.init(x: width, y: height))
              //
              //    rectangle.close()

//    UIGraphicsBeginImageContextWithOptions(newLayer.bounds.size, previewLayer.isOpaque, 0.0)
//    previewLayer.render(in: UIGraphicsGetCurrentContext()!)
//    let img = UIGraphicsGetImageFromCurrentImageContext()
//    UIGraphicsEndImageContext()
//    UIImageWriteToSavedPhotosAlbum(img!, nil, nil, nil)
    
                //    let rec = CAShapeLayer.init()
                //    rec.path = rectangle.cgPath
                //    rec.fillColor = UIColor.red.cgColor
                //    self.view.layer.addSublayer(rec)

//    if let leftEyebrow = landmark(
//      points: landmarks.leftEyebrow?.normalizedPoints,
//      to: result.boundingBox) {
//      faceView.leftEyebrow = leftEyebrow
//    }
//
//    if let rightEyebrow = landmark(
//      points: landmarks.rightEyebrow?.normalizedPoints,
//      to: result.boundingBox) {
//      faceView.rightEyebrow = rightEyebrow
//    }
//
//    if let nose = landmark(
//      points: landmarks.nose?.normalizedPoints,
//      to: result.boundingBox) {
//      faceView.nose = nose
//    }
//
//    if let outerLips = landmark(
//      points: landmarks.outerLips?.normalizedPoints,
//      to: result.boundingBox) {
//      faceView.outerLips = outerLips
//    }
//
//    if let innerLips = landmark(
//      points: landmarks.innerLips?.normalizedPoints,
//      to: result.boundingBox) {
//      faceView.innerLips = innerLips
//    }
//
//    if let faceContour = landmark(
//      points: landmarks.faceContour?.normalizedPoints,
//      to: result.boundingBox) {
//      faceView.faceContour = faceContour
//    }
  }

  // 1
  func updateLaserView(for result: VNFaceObservation) {
    // 2
    laserView.clear()

    // 3
    let yaw = result.yaw ?? 0.0

    // 4
    if yaw == 0.0 {
      return
    }

    // 5
    var origins: [CGPoint] = []

    // 6
    if let point = result.landmarks?.leftPupil?.normalizedPoints.first {
      let origin = landmark(point: point, to: result.boundingBox)
      origins.append(origin)
    }

    // 7
    if let point = result.landmarks?.rightPupil?.normalizedPoints.first {
      let origin = landmark(point: point, to: result.boundingBox)
      origins.append(origin)
    }

    // 1
    let avgY = origins.map { $0.y }.reduce(0.0, +) / CGFloat(origins.count)

    // 2
    let focusY = (avgY < midY) ? 0.75 * maxY : 0.25 * maxY

    // 3
    let focusX = (yaw.doubleValue < 0.0) ? -100.0 : maxX + 100.0

    // 4
    let focus = CGPoint(x: focusX, y: focusY)

    // 5
    for origin in origins {
      let laser = Laser(origin: origin, focus: focus)
      laserView.add(laser: laser)
    }

    // 6
    DispatchQueue.main.async {
      self.laserView.setNeedsDisplay()
    }
  }
  

  func detectedFace(request: VNRequest, error: Error?) {
    // 1
    guard
      let results = request.results as? [VNFaceObservation],
      let result = results.first
      else {
        // 2
        faceView.clear()
        return
    }

    if faceViewHidden {
      updateLaserView(for: result)
    } else {
      updateFaceView(for: result)
    }
  }
 
}
/*
//new part for picture
@IBOutlet weak var imageTake: UIImageView!
var imagePicker: UIImagePickerController!

enum ImageSource {
    case photoLibrary
    case camera
}


//MARK: - Take image
@IBAction func takePhoto(_ sender: UIButton) {
    guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
        selectImageFrom(.photoLibrary)
        return
    }
    selectImageFrom(.camera)
}

func selectImageFrom(_ source: ImageSource){
    imagePicker =  UIImagePickerController()
    imagePicker.delegate = self
    switch source {
    case .camera:
        imagePicker.sourceType = .camera
    case .photoLibrary:
        imagePicker.sourceType = .photoLibrary
    }
    present(imagePicker, animated: true, completion: nil)
}

//MARK: - Saving Image here
@IBAction func save(_ sender: AnyObject) {
    guard let selectedImage = imageTake.image else {
        print("Image not found!")
        return
    }
    UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
}

//MARK: - Add image to Library
@objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
    if let error = error {
        // we got back an error!
        showAlertWith(title: "Save error", message: error.localizedDescription)
    } else {
        showAlertWith(title: "Saved!", message: "Your image has been saved to your photos.")
    }
}

func showAlertWith(title: String, message: String){
    let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
    ac.addAction(UIAlertAction(title: "OK", style: .default))
    present(ac, animated: true)
}
}

extension FaceDetectionViewController{
func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){
    imagePicker.dismiss(animated: true, completion: nil)
    guard let selectedImage = info[.originalImage] as? UIImage else {
        print("Image not found!")
        return
    }
    imageTake.image = selectedImage
}
*/
