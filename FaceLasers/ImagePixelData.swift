import UIKit
/*
 1.Da ja zemime goleminata na slikata vo pikseli od kvadratcheto 100x100 (momentalno se zema cela golemina)
 func getImageSize(image: UIImage) -> CGSize
 
 2.Da se napravi resize na slikata so pomala golemina i pikseli za pooptimalna obrabotka na slikata
 
 3.Da zemime boja na pikselot pr.double
 
 !-Da se validiraat vrednostite koi se dobieni od rgbalpha dali se validni
 
 4.vo for loop da se izvrtat site pikseli od slikata, da se zeme bojata na sekoj piksel i da se zachuva vo struktura ImageData
 
 DONE!
*/

struct ImageData{
  var x:Int;
  var y:Int;
  var r:Double;
  var g:Double;
  var b:Double;
  var alpha:Double;
}

/// Process the image data.
///
/// - Parameter image: `UIImage`
/// - Returns: `[ImageData]?` The processed data. Array of `ImageData` model.
func processImage(image: UIImage) -> [ImageData]? {
  
  var data: [ImageData]? = []
  
  let testImage = image.resize(to: CGSize(width: 100, height: 70))
  
//  let widthInPixels = image.size.width * image.scale
//  let heightInPixels = image.size.height * image.scale
  
  let imageWidth = testImage?.size.width
  let imageHeight = testImage?.size.height
  
  
  for i in 1...Int(imageWidth! - 1){
    for j in 1...Int(imageHeight! - 1){
//      print("x:\(i) y:\(j) ")
        
      let pixelColor = testImage?.pixelColor(x: i, y: j)
      let color = pixelColor?.rgb()
      
//      print(color)
      
     let elementData = ImageData(x: i, y: j,
                                 r: Double(color!.red),
                                 g: Double(color!.green),
                                 b: Double(color!.blue),
                                 alpha: Double(color!.alpha))
      
      data?.append(elementData)
    }
  }

  return data

}
