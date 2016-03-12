//
//  AcclerometerClass.swift
//  ACC
//
//  Created by KWC-team on 15/10/31.
//  Copyright © 2015 KWC-team. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import CoreMotion

class Gyro:UIViewController {
    //lazy var motionManager = CMMotionManager()
    lazy var manager = CMMotionManager()
    lazy var queue = NSOperationQueue.mainQueue()
    var gyrox=0.0
    var gyroy=0.0
    var gyroz=0.0
    //let viewcontroller=ViewController()

//    func getGyro() {
//        let viewcontroller = ViewController()
//        
//        manager.gyroUpdateInterval=1
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//        let managedContext = appDelegate.managedObjectContext
//        let entityName = NSStringFromClass(Accelerometer.classForCoder())
//        
//        if manager.gyroAvailable{
//            
//            if manager.gyroActive == false{
//                
//                manager.gyroUpdateInterval = 1.0 / 40.0
//                
//                manager.startGyroUpdatesToQueue(queue,
//                    withHandler: {data, error in
//                        
//                        guard let data = data else{
//                            return
//                        }
//                        
//                        print("Gyro Rotation x = \(data.rotationRate.x)")
//                        print("Gyro Rotation y = \(data.rotationRate.y)")
//                        print("Gyro Rotation z = \(data.rotationRate.z)")
//                        
//                })
//                
//            } else {
//                print("Gyro is already active")
//            }
//            
//        } else {
//            print("Gyro isn't available")
//        }
//    
//
//    }
}