//
//  PhotosFrameworkViewController.swift
//  Hipstagram
//
//  Created by Kori Kolodziejczak on 10/18/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

import UIKit
import Photos

class PhotosFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var assetFetchResults: PHFetchResult!
  var assetCollection: PHAssetCollection!
  var imageManager: PHCachingImageManager!
  var assetCellSize: CGSize!
  
  var delegate: GalleryDelegate?

  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //THIS IS THE START OF NEW STUFF WE LEARNED ON DAY 3
    
    // Get image image, asset fetch results
    self.imageManager = PHCachingImageManager()
    
    // Pass nil, fetch all assets
    self.assetFetchResults = PHAsset.fetchAssetsWithOptions(nil)
    
    // Determine device scale, adjust asset cell size
    var scale = UIScreen.mainScreen().scale
        var flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout

        var cellSize = flowLayout.itemSize
        self.assetCellSize = CGSizeMake(cellSize.width * scale, cellSize.height * scale)
      }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return self.assetFetchResults.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
      let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHASSET_CELL", forIndexPath: indexPath) as PHAssetCell
      
//      var currentTag = cell.tag + 1
//      cell.tag = currentTag
      
      var asset = self.assetFetchResults[indexPath.row] as PHAsset
      
      self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
        cell.imageView.image = image
        
//        if cell.tag == currentTag {
//          cell.imageView.image = image
//        }
      }
      
      return cell
    }
  
  
  func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
    var asset = self.assetFetchResults[indexPath.row] as PHAsset
    println("TAP")
    self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options:  nil) { (image, info) -> Void in
      self.delegate?.didTapOnPicture(image)
      self.dismissViewControllerAnimated(true, completion: nil)
    }
  }
    
}