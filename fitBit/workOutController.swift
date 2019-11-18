//
//  workOutController.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 05/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import UIKit
import CoreLocation

class workOutController: UIViewController, CLLocationManagerDelegate {
    
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var time: Int = 0
    var timer = Timer()
    
    /******UI ELEMENTS*********/
    @IBOutlet weak var saveBut: UIButton!
    @IBOutlet weak var startBut: UIButton!
    @IBOutlet weak var resumeBut: UIButton!
    @IBOutlet weak var stopBut: UIButton!
    @IBOutlet weak var hoursLab: UITextView!
    @IBOutlet weak var minutesLab: UITextView!
    @IBOutlet weak var secondsLab: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBut.isHidden=true
        resumeBut.isHidden=true
        
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        
        locationManager.startUpdatingLocation()
        
    }
    
    @IBAction func chrono_start(_ sender: Any) {
        print("This is it !!");
        stopBut.isHidden = false;
        /*saveBut.isHidden=false
        resumeBut.isHidden=false*/
        startBut.isHidden=true
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(ended), userInfo: nil, repeats: true)
    }
    
    @IBAction func chrono_stop(_ sender: Any) {
        saveBut.isHidden=false
        resumeBut.isHidden=false
        startBut.isHidden=true
        stopBut.isHidden=true
        timer.invalidate();
    }
    
    @IBAction func resume_chrono(_ sender: Any) {
        resumeBut.isHidden = true
        saveBut.isHidden = true
        stopBut.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(ended), userInfo: nil, repeats: true)
    }
    
    @IBAction func save_chrono(_ sender: Any) {
        saveBut.isHidden = true
        resumeBut.isHidden = true
        startBut.isHidden=false
        
        time=0;
        updateUI();
    }
    
    @objc private func ended(){
        time += 1;
        updateUI();
    }
    private func updateUI(){
        var hours: Int
        var min: Int
        var sec: Int
        
        hours = time / (60*60)
        min = (time/60)%60
        sec = time % 60
        
        hoursLab.text = String(hours)
        if(min < 10){
            minutesLab.text = "0"+String(min)
        }else{
            minutesLab.text = String(min)
        }
        if(sec < 10){
            secondsLab.text = "0"+String(sec)
        }else{
            secondsLab.text = String(sec)
        }
        
        
    }
    
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
