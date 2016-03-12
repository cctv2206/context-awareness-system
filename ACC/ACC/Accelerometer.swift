//
//  Accelerometer.swift
//  ACC
//
//  Created by KWC-team on 15/10/31.
//  Copyright © 2015 KWC-team. All rights reserved.
//

import Foundation
import CoreData
@objc(Accelerometer) class Accelerometer: NSManagedObject {
    
    @NSManaged var accX: Double
    @NSManaged var accY: Double
    @NSManaged var accZ: Double
    
}
