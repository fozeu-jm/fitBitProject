//
//  workOutController.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 05/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import UIKit
import CoreLocation
import SQLite3

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
    
    
    var db : OpaquePointer?
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBut.isHidden=true
        resumeBut.isHidden=true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        loadDB()
        
    }
    
    func loadDB(){
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fitbit.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening file")
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS fitbit ( id INTEGER PRIMARY KEY AUTOINCREMENT , startTime DATETIME NOT NULL , EndTime DATETIME NOT NULL , duration INTEGER NOT NULL , distance DOUBLE NOT NULL , locat_id INT NOT NULL)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error initialising the file")
        }else{
            print("Err thhing is OK !")
        }
    }
    
    @IBAction func chrono_start(_ sender: Any) {
        stopBut.isHidden = false;
        /*saveBut.isHidden=false
        resumeBut.isHidden=false*/
        startBut.isHidden=true
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(ended), userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func chrono_stop(_ sender: Any) {
        saveBut.isHidden=false
        resumeBut.isHidden=false
        startBut.isHidden=true
        stopBut.isHidden=true
        timer.invalidate();
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func resume_chrono(_ sender: Any) {
        resumeBut.isHidden = true
        saveBut.isHidden = true
        stopBut.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(ended), userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
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
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for currentLocation in locations{
            print("\(String(describing: index)): \(currentLocation)")
            //
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
