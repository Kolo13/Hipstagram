//
//  Filter.swift
//  Hipstagram
//
//  Created by Kori Kolodziejczak on 10/15/14.
//  Copyright (c) 2014 Kori Kolodziejczak. All rights reserved.
//

import Foundation
import CoreData

class Filter: NSManagedObject {

    @NSManaged var favorited: NSNumber
    @NSManaged var name: String

}
