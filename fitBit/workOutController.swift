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
    @IBOutlet weak var metersLab: UITextView!
    @IBOutlet weak var saveBut: UIButton!
    @IBOutlet weak var startBut: UIButton!
    @IBOutlet weak var resumeBut: UIButton!
    @IBOutlet weak var stopBut: UIButton!
    @IBOutlet weak var hoursLab: UITextView!
    @IBOutlet weak var minutesLab: UITextView!
    @IBOutlet weak var secondsLab: UITextView!
    
    var db : OpaquePointer?
    var allLocations: Array<CLLocation> = Array()
    var test = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveBut.isHidden=true
        resumeBut.isHidden=true
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        allLocations.removeAll()
        allLocations.removeAll()
        allLocations.removeAll()
        allLocations.removeAll()
        
        loadDB()
        
        var stmt2 : OpaquePointer?
        
        let select = "SELECT * FROM fitBit"
        
        //let truncate = "DELETE FROM fitBit"
        
       // let drop2 = "ALTER TABLE fitBit ADD COLUMN sourLat DOUBLE NOT NULL, ADD COLUMN sourLong DOUBLE NOT NULL, ADD COLUMN destLat DOUBLE NOT NULL, ADD COLUMN destLong DOUBLE NOT NULL"
        //let drop = "DROP TABLE IF EXISTS fitBit"
        
        if sqlite3_prepare(db, select, -1, &stmt2, nil) == SQLITE_OK {
            
            while sqlite3_step(stmt2) == SQLITE_ROW {
                
                let date = UnsafePointer<UInt8>(sqlite3_column_text(stmt2, 2))!
                let start = String(cString: date)
                let duration = sqlite3_column_int(stmt2, 3)
                let distance = sqlite3_column_double(stmt2, 4)
                let sour = sqlite3_column_double(stmt2, 6)
                
                 print("Date: "+start+" - "+"Duration: "+String(duration)+" - "+"Distance: "+String(distance)+" - "+"sourLat: "+String(sour))
            }
        }else{
            print(String.init(cString: sqlite3_errmsg(db)))
        }
        
        
    }
    
    func loadDB(){
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fitbit.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening file")
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS fitBit ( id INTEGER PRIMARY KEY AUTOINCREMENT , startTime DATETIME NOT NULL , EndTime DATETIME NOT NULL , duration INTEGER NOT NULL , distance DOUBLE NOT NULL, sourLat  DOUBLE NOT NULL, sourLong DOUBLE NOT NULL, destLat DOUBLE NOT NULL, destLong DOUBLE NOT NULL)"
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error initialising the file")
        }else{
            print("File succesfully initialised !")
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
        
        
        
        
        var stmt : OpaquePointer?
        
        let insert = "INSERT INTO fitBit (startTime, EndTime,duration,distance,sourLat,sourLong,destLat,destLong) VALUES (?, ?, ?, ?, ?, ?, ?, ?)"
        
        if sqlite3_prepare(db, insert, -1, &stmt, nil) != SQLITE_OK {
            print("ERROR BINDING QUERY")
        }
        
        let first : CLLocation = allLocations.first!
        let last : CLLocation = allLocations.last!
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = df.string(from: first.timestamp)
        if sqlite3_bind_text(stmt, 1, date, -1, nil) != SQLITE_OK{
            print("Binding value exception")
        }
        
        let df2 = DateFormatter()
        df2.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date2 = df2.string(from: last.timestamp)
        if sqlite3_bind_text(stmt, 2, date2, -1, nil) != SQLITE_OK{
            print("Binding value exception")
        }
        
        if sqlite3_bind_int(stmt, 3, Int32(time)) != SQLITE_OK{
            print("Error binding duration")
        }
        
        
        var distance: CLLocationDistance = 0.0
        distance = first.distance(from: last)
        
        if sqlite3_bind_double(stmt, 4, distance) != SQLITE_OK{
            print("Error binding duration")
        }
        
        if sqlite3_bind_double(stmt, 5, first.coordinate.latitude) != SQLITE_OK{
            print("Error binding duration")
        }
        
        if sqlite3_bind_double(stmt, 6, first.coordinate.longitude) != SQLITE_OK{
            print("Error binding duration")
        }
        
        if sqlite3_bind_double(stmt, 7, last.coordinate.longitude) != SQLITE_OK{
            print("Error binding duration")
        }
        
        if sqlite3_bind_double(stmt, 8, last.coordinate.longitude) != SQLITE_OK{
            print("Error binding duration")
        }
        
        if sqlite3_step(stmt) == SQLITE_DONE{
            print("Workout succesfully saved !")
        }else{
            print("Error writing data to disk !")
        }
        
        
        time=0;
        updateUI();
        metersLab.text = "0.00 metres"
        allLocations.removeAll()
        test = 0
        
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
            
        if(test > 1){
            
            if(allLocations.first != nil && allLocations != nil){
                let first : CLLocation = allLocations.first!
                let last : CLLocation = allLocations.last!
                var distance: CLLocationDistance = 0.0
                distance = first.distance(from: last)
                
                metersLab.text = String(format: "%.2f",distance)+" metres"
            }
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //print(locations[0])
        
        if(test > 1){
            allLocations.append(locations[0])
        }else{
           // allLocations.removeAll()
            test+=1
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
