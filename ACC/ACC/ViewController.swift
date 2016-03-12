//
//  ViewController.swift
//  ACC
//
//  Created by KWC-team on 15/10/31.
//  Copyright © 2015 KWC-team. All rights reserved.
//

import UIKit
import CoreMotion
import CoreData
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    lazy var motionManager = CMMotionManager()
    
    var manager:CLLocationManager!
    

    var AcData: [[Double]] = []    // accelerometer data
    var AcDataFiltered: [[Double]] = [] //filtered data
    var SpeedData: [Double] = [] // speed data
    
    var Count: Int = 1
    
    let AcUpdateInterval = 0.02 // sampling rate
    let CycleInterval = 3.0 // how many sec for a cycle
    let ALPHA = 0.0314 // the alpha in the filter
    var LastOfLastCycle:[Double] = []
    
    var accx=0.0
    var accy=0.0
    var accz=0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Setup our Location Manager
        manager = CLLocationManager()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.requestAlwaysAuthorization()
        
        
    }
    
    @IBOutlet weak var currentResultX: UILabel!
    
    @IBOutlet weak var currentResultY: UILabel!
    
    @IBOutlet weak var currentResultZ: UILabel!
    
    @IBOutlet weak var maxResultX: UILabel!
    
    @IBOutlet weak var maxResultY: UILabel!
    
    @IBOutlet weak var maxResultZ: UILabel!
    
    @IBOutlet weak var LabelDoingWhat: UILabel!
   
    @IBAction func Start(sender: AnyObject) {
        manager.startUpdatingLocation()//start
        let CountMax = self.CycleInterval / self.AcUpdateInterval
        
        print("CountMax =",CountMax)
        
        motionManager.accelerometerUpdateInterval = self.AcUpdateInterval
        
        
        if motionManager.accelerometerAvailable{
            let queue = NSOperationQueue.mainQueue()
            motionManager.startAccelerometerUpdatesToQueue(queue, withHandler:
                {data, error in
                    
                    guard let data = data else{
                        return
                    }
                    
                    let ThisAcData = [data.acceleration.x, data.acceleration.y, data.acceleration.z]
                    self.AcData.append(ThisAcData)
                    
                    //get the filtered data
                    var ThisAcDataFiltered = []
                    var LastAcDataFiltered:[Double] = []
                    if self.AcDataFiltered.count == 0 { // the first data of a cycle
                        if self.LastOfLastCycle.count != 0{ //we have something from the last cycle
                            LastAcDataFiltered = self.LastOfLastCycle
                        }else{ //this is the every first cycle
                            LastAcDataFiltered = [0,0,0]
                        }
                    }else{ // in the middle of the cycle
                        LastAcDataFiltered = self.AcDataFiltered[self.AcDataFiltered.endIndex-1]
                    }
                    
                    let thisX = LastAcDataFiltered[0]+self.ALPHA*(ThisAcData[0] - LastAcDataFiltered[0])
                    let thisY = LastAcDataFiltered[1]+self.ALPHA*(ThisAcData[1] - LastAcDataFiltered[1])
                    let thisZ = LastAcDataFiltered[2]+self.ALPHA*(ThisAcData[2] - LastAcDataFiltered[2])
                    
                    ThisAcDataFiltered = [thisX, thisY, thisZ]
                    
                    self.AcDataFiltered.append(ThisAcDataFiltered as! [Double])

                    //print("3a \(data.acceleration.x) \(data.acceleration.y) \(data.acceleration.z)")
                    //print("3aFiltered \(ThisAcDataFiltered[0]) \(ThisAcDataFiltered[1]) \(ThisAcDataFiltered[2])")
                    
                    if self.Count >= Int(CountMax) { //cycle end, do the calculation
                        
                        self.LastOfLastCycle = self.AcDataFiltered[self.AcDataFiltered.endIndex-1]
                        
                        // calculate the threshold
                        var AcDataFilteredX:[Double] = []
                        var AcDataFilteredY:[Double] = []
                        var AcDataFilteredZ:[Double] = []
                        for i in self.AcDataFiltered {
                            AcDataFilteredX.append(i[0])
                            AcDataFilteredY.append(i[1])
                            AcDataFilteredZ.append(i[2])
                        }
                        let XYZ = [abs(self.average(AcDataFilteredX)),abs(self.average(AcDataFilteredY)),abs(self.average(AcDataFilteredZ))]
                        
                        let Threshold = XYZ.maxElement()! * 2.0
                        
                        let WhichAxis = XYZ.indexOf(XYZ.maxElement()!)

                        // walking or running??
                        var OverThresholdCount = 0.0
                        
                        //calculate the step rate
                        var StepRateCount = 0
                        
                        var lastData: [Double] = []
                        // how many points are greater than threshold
                        // and whats the step rate
                        for i in self.AcData {
                            // count the step rate
                            let ThresholdStep = Threshold * 0.6
                            if lastData.count != 0{
                                if (abs(lastData[WhichAxis!]) < ThresholdStep && abs(i[WhichAxis!]) >= ThresholdStep ){
                                    StepRateCount = StepRateCount+1
                                }
                            }
                            // count the over threshold data
                            if abs(i[WhichAxis!]) >= Threshold {
                                OverThresholdCount = OverThresholdCount+1.0
                            }
                            lastData = i
                        }
                        
                        print("step rate count = ", StepRateCount)
                        
                        if OverThresholdCount >= Double(self.AcData.count) * 0.1 { // running!!
                            self.LabelDoingWhat.text = "Running"
                            print("Running")
                        }else{ // not running
                            if StepRateCount <= 2{
                                self.LabelDoingWhat.text = "Stand by"
                                print("Stand by")
                            }else{
                                self.LabelDoingWhat.text = "Walking"
                                print("Walking")
                            }
                        }
                        
                        // init
                        self.AcData = []
                        self.SpeedData = []
                        self.AcDataFiltered = []
                        self.Count = 1
                        
                    }else{ // not the end, continue
                        self.Count = self.Count+1
                    }
                    
                }
            )
            
        } else {
            print("Accelerometer is not available")
            
        }
    }

    @IBAction func Stop(sender: AnyObject) {
        manager.stopUpdatingLocation()
        
        motionManager.stopAccelerometerUpdates()
        self.currentResultX.text="0"
        self.currentResultZ.text="0"
        self.currentResultY.text="0"
        self.maxResultX.text="0"
        self.maxResultY.text="0"
        self.maxResultZ.text="0"
        
        self.LabelDoingWhat.text = "Doing What??"
        
    }
    
    func locationManager(manager:CLLocationManager, didUpdateLocations locations:[CLLocation])
    {
        let speed = manager.location!.speed
        let theTime = manager.location!.timestamp
        self.SpeedData.append(speed)
        print("speed \(speed) \(theTime)")
        
    }
    
    // calculate the average of an array
    func average(nums: [Double]) -> Double {
        var total = 0.0
        //use the parameter-array instead of the global variable votes
        for vote in nums{
            total += Double(vote)
        }
        
        let votesTotal = Double(nums.count)
        let average = total/votesTotal
        return average
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

