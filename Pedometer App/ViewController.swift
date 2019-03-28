//
//  ViewController.swift
//  Pedometer App
//
//  Created by The Taste Affair on 15/02/19.
//  Copyright © 2019 Raghav Sethi. All rights reserved.
//

import UIKit
import CoreMotion

let stopColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
let startColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
// values for the pedometer data
var numberOfSteps:Int! = nil
var distance:Double! = nil
var averagePace:Double! = nil
var pace:Double! = nil

class ViewController: UIViewController {

    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var stepsLabel: UILabel!
    @IBOutlet weak var paceLabel: UILabel!
    @IBOutlet weak var avgPaceLabel: UILabel!
    @IBOutlet weak var distaceLabel: UILabel!
    
    @IBAction func startStopButton(_ sender: UIButton) {
        
        if sender.titleLabel?.text == "Start"   {
            //Start the pedometer
            pedometer = CMPedometer()
            startTimer() //start the timer
            pedometer.startUpdates(from: Date()) { (pedometerData, error) in
                if let pedData = pedometerData  {
                    self.numberOfSteps = Int(truncating: pedData.numberOfSteps)
                   // self.stepsLabel.text! = "Steps:\(pedData.numberOfSteps)"
                    print(pedData.numberOfSteps)
               
                if let distance = pedData.distance{
                    self.distance = Double(truncating: distance)
                }
                if let averageActivePace = pedData.averageActivePace {
                    self.averagePace = Double(truncating: averageActivePace)
                }
                if let currentPace = pedData.currentPace {
                    self.pace = Double(truncating: currentPace)
                }
                     }
                else    {
                    self.stepsLabel.text! = "Steps: Not Available"
                }
            }
            //Toggle the UI to On state
            statusTitle.text = "Pedometer On"
            sender.setTitle("Stop", for: .normal)
            sender.backgroundColor = stopColor
        }
        else{
            //Stop the pedometer
            pedometer.stopUpdates()
            stopTimer() //stop the timer
            //Toggle the UI to OFF state
            statusTitle.text = "Pedometer Off: " + timeIntervalFormat(interval: timeElasped)
            sender.setTitle("Start", for: .normal)
            sender.backgroundColor = startColor
        }
        
    }
    
    let stopColor = UIColor(red: 1.0, green: 0.0, blue: 0.0, alpha: 1.0)
    let startColor = UIColor(red: 0.0, green: 0.75, blue: 0.0, alpha: 1.0)
    // values for the pedometer data
    var numberOfSteps:Int! = nil
    var distance:Double! = nil
    var averagePace:Double! = nil
    var pace:Double! = nil
    
    var pedometer = CMPedometer()
    
    //timer
    var timer = Timer()
    let timerInterval = 1.0
    var timeElasped:TimeInterval = 0.0
    
    //MARK - Display and time format functions
    
    //convert seconds to hh:mm:ss as a string
    func timeIntervalFormat(interval : TimeInterval) -> String  {
        var seconds = Int(interval + 0.5)
        let hours = seconds/3600
        let minutes = (seconds/60)%60
        seconds = seconds % 60
        return String(format: "%02i:%02i:%02i", hours,minutes,seconds)
    }
    
    // convert the pace in meters per second to a string with
    //the meteric m/s and the imperial mintues per mile
    
    func paceString(title:String,pace:Double) -> String {
        var minPerMile = 0.0
        let factor = 26.8224 //conversion faactor
        if pace != 0    {
            minPerMile = factor / pace
        }
        let minutes = Int(minPerMile)
        let seconds = Int(minPerMile*60)%60
        return String(format: "%@:%02.2f m/s \n\t\t %02i:%02i min/mi", title,pace,minutes,seconds)
    }
    
    //MARK: - timer functions
    func startTimer(){
        if timer.isValid { timer.invalidate() }
        timer = Timer.scheduledTimer(timeInterval: timerInterval,target: self,selector: #selector(timerAction(timer:)) ,userInfo: nil,repeats: true)
    }
    
    func stopTimer(){
        timer.invalidate()
        displayPedometerData()
    }
    
    @objc func timerAction(timer:Timer){
        displayPedometerData()
    }
    func displayPedometerData() {
        
        timeElasped += 1.0
        statusTitle.text = "On : " + timeIntervalFormat(interval: timeElasped)
        //Number of steps
        if let numberOfSteps = self.numberOfSteps{
            stepsLabel.text! = String(format:"Steps: %i",numberOfSteps)
        }
        
        //distance
        if let distance = self.distance{
            distaceLabel.text = String(format:"Distance: %02.02f meters,\n %02.02f mi",distance,miles(meters: distance))
        } else {
            distaceLabel.text = "Distance: N/A"
        }
        
        //average pace
        if let averagePace = self.averagePace{
            avgPaceLabel.text = paceString(title: "Avg Pace", pace: averagePace)
        } else {
            avgPaceLabel.text =  paceString(title: "Avg Comp Pace", pace: computedAvgPace())
        }
        
        //pace
        if let pace = self.pace {
            print(pace)
            paceLabel.text = paceString(title: "Pace:", pace: pace)
        } else {
            paceLabel.text = "Pace: N/A "
            paceLabel.text =  paceString(title: "Avg Comp Pace", pace: computedAvgPace())
        }
        
    }
    
    func computedAvgPace() -> Double    {
        if let distance = self.distance{
            pace = distance / timeElasped
            return pace
        }
        else    {
            return 0.0
        }
    }
    
    func miles(meters:Double) -> Double{
        let mile = 0.000621371192
        return meters*mile
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }


}

