//
//  PhotoFrameworkViewController.swift
//  Hipstagram
//
//  Created by Kori Kolodziejczak on 10/18/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

import UIKit
import Photos

class PhotoFrameworkViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var assetFetchResults: PHFetchResult!
  var assetCollection: PHAssetCollection!
  var imageManager: PHCachingImageManager!
  var assetCellSize: CGSize!
  var vcCellSize: CGSize!
  var delegate: GalleryDelegate?
  
  @IBOutlet weak var collectionView: UICollectionView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
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
    
    var asset = self.assetFetchResults[indexPath.row] as PHAsset
    
    self.imageManager.requestImageForAsset(asset, targetSize: self.assetCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
      cell.imageView.image = image
    }
    
    return cell
  }

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    var asset = self.assetFetchResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: vcCellSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (image, info) -> Void in
      self.delegate?.didTapOnPicture(image)
      self.dismissViewControllerAnimated(true, completion: nil)
      }
  }
}
