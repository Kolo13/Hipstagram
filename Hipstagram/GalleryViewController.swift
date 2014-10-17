//
//  GALLERYViewController.swift
//  Hipstagram
//
//  Created by Kori Kolodziejczak on 10/16/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

import UIKit

protocol GalleryDelegate {
  
  func didTapOnPicture (image: UIImage)
}

class GALLERYViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {

var images = [UIImage]()
var delegate: GalleryDelegate?
var flowlayout : UICollectionViewFlowLayout!


  @IBOutlet weak var collectionView: UICollectionView!
  
  
    override func viewDidLoad() {
        super.viewDidLoad()
      
      
      var image1 = UIImage(named: "photo-1.jpg")
      var image2 = UIImage(named: "photo-2.jpg")
      var image3 = UIImage(named: "photo-3.jpg")
      var image4 = UIImage(named: "photo-4.jpg")
      var image5 = UIImage(named: "photo-5.jpg")
      
      self.images.append(image1!)
      self.images.append(image2!)
      self.images.append(image3!)
      self.images.append(image4!)
      self.images.append(image5!)

      self.flowlayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
        // Do any additional setup after loading the view.
      
      var pinch = UIPinchGestureRecognizer(target: self, action: "pinchAction:")
      self.collectionView.addGestureRecognizer(pinch)

    }
  
    func pinchAction(pinch : UIPinchGestureRecognizer) {
      
      
      if pinch.state == UIGestureRecognizerState.Ended {
        println(pinch.velocity)
        self.collectionView.performBatchUpdates({ () -> Void in
          if pinch.velocity > 0 {
            self.flowlayout.itemSize = CGSize(width: self.flowlayout.itemSize.width * 2, height: self.flowlayout.itemSize.height * 2)
          } else {
            self.flowlayout.itemSize = CGSize(width: self.flowlayout.itemSize.width * 0.5, height: self.flowlayout.itemSize.height * 0.5)
          }
          }, completion: nil )
      }
    
  }

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.images.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    cell.galleryCell.image = images[indexPath.row]
    
    
    return cell
  }
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    self.delegate?.didTapOnPicture(self.images[indexPath.row])
    self.dismissViewControllerAnimated(true, completion: nil)
  }

}
