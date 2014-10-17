//
//  File.swift
//  Hipstagram
//
//  Created by Kori Kolodziejczak on 10/15/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

import Foundation
import UIKit



class ThumbnailContainer {
  
  var filterName: String
  var originalThumbnail: UIImage
  var filteredThumbnail: UIImage?
  var imageQueue: NSOperationQueue?
  var gpuContext: CIContext
  var ciFilter: CIFilter?
  
  init(name: String, thumbnail: UIImage, queue: NSOperationQueue, context: CIContext) {
    self.originalThumbnail = thumbnail
    self.filterName = name

    self.imageQueue = queue
    self.gpuContext = context
    
  }

  
  
  func generateThumbnail ( completionHandler : (image : UIImage) -> Void  ) {
    self.imageQueue?.addOperationWithBlock({ () -> Void in
      
      //setting up your filter with a CIImage
      var image = CIImage(image: self.originalThumbnail)
      var imgFilter = CIFilter(name: self.filterName)
      imgFilter.setDefaults()
      imgFilter.setValue(image, forKey: kCIInputImageKey)
      
      //generate the results
      var result = imgFilter.valueForKey(kCIOutputImageKey) as CIImage
      var extent = result.extent()
      var imgRef = self.gpuContext.createCGImage(result, fromRect: extent)
      self.ciFilter = imgFilter
      
      
      NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
        self.filteredThumbnail = UIImage(CGImage: imgRef)
        completionHandler(image: self.filteredThumbnail!)
      })
      
    })
  }

}