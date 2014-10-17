//
//  ViewController.swift
//  Hipstagram
//
//  Created by Kori Kolodziejczak on 10/15/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

import UIKit
import CoreData
import CoreImage

class ViewController: UIViewController, GalleryDelegate, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  @IBOutlet weak var imageView: UIImageView!
  @IBOutlet weak var imageViewBottomConstrain: NSLayoutConstraint!
  @IBOutlet weak var imageViewLeadingConstrain: NSLayoutConstraint!
  @IBOutlet weak var imageViewTrailingConstrain: NSLayoutConstraint!
  
  
  
  @IBOutlet weak var filterCollectionView: UICollectionView!
  @IBOutlet weak var filterCollectionViewBottomConstrain: NSLayoutConstraint!
  
  var managedObjectContext: NSManagedObjectContext!
  var filters : [Filter]?
  var originalThumbnail: UIImage?
  var imageQueue = NSOperationQueue()
  var thumbnailContainers = [ThumbnailContainer]()
  var gpuContext : CIContext?


  override func viewDidLoad() {
    super.viewDidLoad()
    
    var options = [kCIContextWorkingColorSpace : NSNull()]
    var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: myEAGLContext, options: options)
  
    let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
    self.managedObjectContext  = appDelegate.managedObjectContext
    
    let fetchRequest = NSFetchRequest(entityName: "Filter")
    var error : NSError?
    // first fetch to see if there are any items in DB
    if let filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as?  [Filter] {
      if filters.isEmpty {
        //its empty, now we gotta seed
        self.seedCoreData()
        self.filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as?  [Filter]
      }else{
        
        self.filters = filters
      }
    }
    self.filterCollectionView.dataSource = self
  }
  
  func seedCoreData() {
    //var newFilter = Filter() //this wont work....have to do like:
    var sepiaFilter = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
    sepiaFilter.name = "CISepiaTone"
    sepiaFilter.favorited = true
    
    var gaussianBlurFilter = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
    gaussianBlurFilter.name = "CIGaussianBlur"
    gaussianBlurFilter.favorited = true
    
    var error : NSError?
    
    //saving the context
    self.managedObjectContext.save(&error)
    if error != nil {
      println(error!.localizedDescription)
    }
  }
  
  func enterFilterMode () {
    self.imageViewLeadingConstrain.constant = self.imageViewLeadingConstrain.constant * 2
    self.imageViewTrailingConstrain.constant = self.imageViewTrailingConstrain.constant * 2
    self.imageViewBottomConstrain.constant = self.imageViewBottomConstrain.constant * 2
    
    self.filterCollectionViewBottomConstrain.constant = 100
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
  }
  
  func exitFilterMode () {
    self.imageViewLeadingConstrain.constant = self.imageViewLeadingConstrain.constant / 2
    self.imageViewTrailingConstrain.constant = self.imageViewTrailingConstrain.constant / 2
    self.imageViewBottomConstrain.constant = self.imageViewBottomConstrain.constant / 2
    
    self.filterCollectionViewBottomConstrain.constant = -100
    
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    })
    
  }


//  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//    if segue.identifier == "GALLERY_SEGUE" {
//      let destinationVC = segue.destinationViewController as GalleryViewController
//      destinationVC.delegate = self
//    }
//    
//  }
  func resetThumbnails() {
    
    //first we generate the thumbnail from the image that was selected
    var size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size)
    self.imageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    
    

    
    //now we need to setup our thumbnail containers
    var newThumbnailContainers = [ThumbnailContainer]()
    
    for var index = 0; index < self.filters?.count; index++ {
      let filter = self.filters![index]
    
      var thumbnailContainer = ThumbnailContainer(name: filter.name, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.gpuContext!)
      
      newThumbnailContainers.append(thumbnailContainer)
    }
    self.thumbnailContainers = newThumbnailContainers


    self.filterCollectionView.reloadData()
  }
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "GALLERY_SEGUE" {
      let destinationVC = segue.destinationViewController as GALLERYViewController
      destinationVC.delegate = self
    }
  }
  
  
  
  //drag outlet to PHoto button
  
  @IBAction func didPushPhotoButton(sender: AnyObject) {
  
    let alertController = UIAlertController(title: "PHOTO", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
    
    let galleryAction = UIAlertAction(title: "GALLERY", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.performSegueWithIdentifier("GALLERY_SEGUE", sender: self)
    }
      
      
    let cameraAction = UIAlertAction(title: "CAMERA", style: UIAlertActionStyle.Default) { (action) -> Void in
      let imagePicker = UIImagePickerController()
      imagePicker.allowsEditing = true
      
      if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
      }
      
      imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
      imagePicker.delegate = self
      self.presentViewController(imagePicker, animated: true, completion: nil)
    }
      
    let filterAction = UIAlertAction(title: "FILTER", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.resetThumbnails()
      self.enterFilterMode()
      
    }
//    
//    let PHAssetAction = UIAlertAction(title: "PHAsset", style: UIAlertActionStyle.Default) { (action) -> Void in
//      let newVC = self.storyboard?.instantiateViewControllerWithIdentifier("GALLERY_VC") as GalleryViewController
//      self.navigationController?.pushViewController(newVC, animated: true)
//
//      
//    }

    
    alertController.addAction(galleryAction)
    alertController.addAction(cameraAction)
    alertController.addAction(filterAction)
    //
    //alertController.addAction(PHAssetAction)
    
    
    self.presentViewController(alertController, animated: true, completion: nil)
  }
  
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.thumbnailContainers.count
  }
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterCell
    let thumbnailContainer = self.thumbnailContainers[indexPath.row]
    if thumbnailContainer.filteredThumbnail != nil {
      cell.filterCell.image = thumbnailContainer.filteredThumbnail
      println("YYYY")
    } else {
      cell.filterCell.image = thumbnailContainer.originalThumbnail
      thumbnailContainer.generateThumbnail({ (filteredThumb) -> (Void) in
        if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterCell {
          cell.filterCell.image = filteredThumb
        }
      })
      
    }
    return cell
  }
  

  func didTapOnPicture(image: UIImage) {
    self.imageView.image = image
    self.resetThumbnails()


  }
}

