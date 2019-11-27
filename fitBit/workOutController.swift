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
import HealthKit

class workOutController: UIViewController, CLLocationManagerDelegate {
    
    
    let locationManager:CLLocationManager = CLLocationManager()
    
    var time: Int = 0
    var timer = Timer()
    var healthStore = HKHealthStore()
    /******UI ELEMENTS*********/
    @IBOutlet weak var metersLab: UITextView!
    @IBOutlet weak var saveBut: UIButton!
    @IBOutlet weak var startBut: UIButton!
    @IBOutlet weak var resumeBut: UIButton!
    @IBOutlet weak var stopBut: UIButton!
    @IBOutlet weak var hoursLab: UITextView!
    @IBOutlet weak var minutesLab: UITextView!
    @IBOutlet weak var secondsLab: UITextView!
    @IBOutlet weak var cancelBut: UIButton!
    
    var db : OpaquePointer?
    var allLocations: Array<CLLocation> = Array()
    var test = 0
    var tracks : [Track] = []
    
    
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
        
        authorizeHealthKit()
        
        
        loadDB()
        
        var stmt2 : OpaquePointer?
        
        let select = "SELECT * FROM fitBit"
        
       // let truncate = "DELETE FROM fitBit"
        
       // let drop2 = "ALTER TABLE fitBit ADD COLUMN sourLat DOUBLE NOT NULL, ADD COLUMN sourLong DOUBLE NOT NULL, ADD COLUMN destLat DOUBLE NOT NULL, ADD COLUMN destLong DOUBLE NOT NULL"
        //let drop = "DROP TABLE IF EXISTS fitBit"
        if sqlite3_prepare(db, select, -1, &stmt2, nil) == SQLITE_OK {
            //sqlite3_step(stmt2)
            var id = Int32(-1)
            while sqlite3_step(stmt2) == SQLITE_ROW {
                    id =  sqlite3_column_int(stmt2, 0)
                let date = UnsafePointer<UInt8>(sqlite3_column_text(stmt2, 2))!
                let start = String(cString: date)
                let duration = sqlite3_column_int(stmt2, 3)
                let distance = sqlite3_column_double(stmt2, 4)
                let sour = sqlite3_column_double(stmt2, 6)
                print("Date: "+start+" - "+"Duration: "+String(duration)+" - "+"Distance: "+String(distance)+" - "+"sourLat: "+String(sour));
            }
            loadTracks(identifier: id)
            let vc = self.tabBarController?.viewControllers![3] as! mapViewController
            vc.sourLat = (tracks.first?.latitude ?? 0.0)
            vc.sourLong = (tracks.first?.longitude ?? 0.0)
            vc.destLat = (tracks.last?.latitude ?? 0.0)
            vc.destLong = (tracks.last?.longitude ?? 0.0)
            vc.tracks = tracks
            
        }else{
            print(String.init(cString: sqlite3_errmsg(db)))
        }
        
        
    }
    
    func saveWorkoutToHealthKit(_ workout: workoutSession) {
        let distanceQuantity = HKQuantity(unit: HKUnit.meter(), doubleValue: workout.distance)
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let startTime = df.date(from: workout.startTime)
        let endTime = df.date(from: workout.endTime)
        

        let hours2 : Double = Double(workout.duration)/3600.0
        let caloriesperHour : Double = 480
        let totalCaloriesBurnt : Double = hours2*caloriesperHour
        print("Calories bruler"+String(totalCaloriesBurnt))
        let unit = HKUnit.kilocalorie()
        let quantity = HKQuantity(unit: unit, doubleValue: totalCaloriesBurnt)
        let workoutObject = HKWorkout(activityType: HKWorkoutActivityType.running, start: startTime!, end: endTime!, duration: TimeInterval(workout.duration), totalEnergyBurned: quantity, totalDistance: distanceQuantity, metadata: nil)
        
        healthStore.save(workoutObject, withCompletion: { (completed, error) in
            if let error = error {
                print("Error creating workout")
                
            } else {
                self.addSamples(hkWorkout: workoutObject, workoutData: workout)
                
            }
        })
        
    }
    
    func addSamples(hkWorkout: HKWorkout, workoutData: workoutSession) {
        var samples = [HKSample]()
        guard let runningDistanceType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning) else { return }
        let distanceUnit = HKUnit.meter()
        let distanceQuantity = HKQuantity(unit: distanceUnit, doubleValue: workoutData.distance)
        
        let df = DateFormatter()
       df.dateFormat = "yyyy-MM-dd HH:mm:ss"
       let startTime = df.date(from: workoutData.startTime)
       let endTime = df.date(from: workoutData.endTime)
        
        let distanceSample = HKQuantitySample(type: runningDistanceType, quantity: distanceQuantity, start: startTime!, end: endTime!)
        samples.append(distanceSample)
        
        healthStore.add(samples, to: hkWorkout, completion: { (completed, error) in
            if let error = error {
                print("Error adding workout samples")
                
            } else {
                print("Workout samples added successfully")
                
            }
            
        })
        
    }
    
    func loadDB(){
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fitbit.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening file")
        }
        
        let createTableQuery = "CREATE TABLE IF NOT EXISTS fitBit ( id INTEGER PRIMARY KEY AUTOINCREMENT , startTime DATETIME NOT NULL , EndTime DATETIME NOT NULL , duration INTEGER NOT NULL , distance DOUBLE NOT NULL, sourLat  DOUBLE NOT NULL, sourLong DOUBLE NOT NULL, destLat DOUBLE NOT NULL, destLong DOUBLE NOT NULL)"
        
        let createTrack = "CREATE TABLE IF NOT EXISTS tracks (session_id INTEGER, latitude DOUBLE NOT NULL, longitude DOUBLE NOT NULL)"
        
        
        if sqlite3_exec(db, createTableQuery, nil, nil, nil) != SQLITE_OK{
            print("Error initialising the file")
        }else{
            print("Sessions File succesfully initialised !")
        }
        
        if sqlite3_exec(db, createTrack, nil, nil, nil) != SQLITE_OK{
            print("Error initialising the file")
        }else{
            print("Track File succesfully initialised !")
        }
       
        
    }
    
    func loadTracks(identifier : Int32){
           var stmt2 : OpaquePointer?
           let select = "SELECT * FROM tracks WHERE session_id = ?"
           
           if sqlite3_prepare(db, select, -1, &stmt2, nil) == SQLITE_OK {
               
           }
           if sqlite3_bind_int(stmt2, 1, identifier) != SQLITE_OK{
               print("Error binding track")
           }
           
           while sqlite3_step(stmt2) == SQLITE_ROW {
               let lat = sqlite3_column_double(stmt2, 1)
               let long = sqlite3_column_double(stmt2, 2)
               let track = Track(latitude: lat, longitude: long)
               tracks.append(track)
           }
           
       }
       
    
    @IBAction func chrono_start(_ sender: Any) {
        stopBut.isHidden = false;
        /*saveBut.isHidden=false
        resumeBut.isHidden=false*/
        startBut.isHidden=true
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(ended), userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 10
    }
    
    @IBAction func chrono_stop(_ sender: Any) {
        saveBut.isHidden=false
        resumeBut.isHidden=false
        cancelBut.isHidden=false
        startBut.isHidden=true
        stopBut.isHidden=true
        timer.invalidate();
        locationManager.stopUpdatingLocation()
    }
    
    @IBAction func resume_chrono(_ sender: Any) {
        resumeBut.isHidden = true
        saveBut.isHidden = true
        cancelBut.isHidden = true
        stopBut.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector:#selector(ended), userInfo: nil, repeats: true)
        locationManager.startUpdatingLocation()
    }
    
    func saveTracks(lastInserted : Int32 ){
        var stmt : OpaquePointer?
               
        let insert = "INSERT INTO tracks (session_id, latitude, longitude) VALUES (?, ?, ?)"
        
        
        for location in allLocations{
            
            if sqlite3_prepare(db, insert, -1, &stmt, nil) != SQLITE_OK {
                print("ERROR BINDING QUERY")
            }
            
            if sqlite3_bind_int(stmt, 1, lastInserted) != SQLITE_OK{
                print("Error binding track")
            }
            
            if sqlite3_bind_double(stmt, 2, location.coordinate.latitude) != SQLITE_OK{
                print("Error binding track")
            }
            
            if sqlite3_bind_double(stmt, 3, location.coordinate.longitude) != SQLITE_OK{
                print("Error binding track")
            }
            
            if sqlite3_step(stmt) == SQLITE_DONE{
                //print("Track saved sucessfully ! !")
            }else{
                print(String.init(cString: sqlite3_errmsg(db)))
            }
            
        }
        
    }
    
    private func authorizeHealthKit() {
      HealthKitSetupAssistant.authorizeHealthKit { (authorized, error) in

          guard authorized else {
              let baseMessage = "HealthKit Authorization Failed"

              if let error = error {
                  print("\(baseMessage). Reason: \(error.localizedDescription)")
              } else {
                  print(baseMessage)
              }

              return
          }

          print("HealthKit Successfully Authorized.")
      }
    }
    
    @IBAction func cancel_chrono(_ sender: Any) {
        saveBut.isHidden = true
        resumeBut.isHidden = true
        cancelBut.isHidden = true
        cancelBut.isHidden=true
        startBut.isHidden=false
        time=0;
        updateUI();
        metersLab.text = "0.00 metres"
        allLocations.removeAll()
        test = 0
    }
    @IBAction func save_chrono(_ sender: Any) {
        saveBut.isHidden = true
        resumeBut.isHidden = true
        cancelBut.isHidden = true
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
        
        if sqlite3_bind_double(stmt, 7, last.coordinate.latitude) != SQLITE_OK{
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
        
        let lastId = "SELECT last_insert_rowid()"
        if sqlite3_prepare(db, lastId, -1, &stmt, nil) != SQLITE_OK {
            print("ERROR BINDING QUERY")
        }
        var lastInsert : Int32
        while sqlite3_step(stmt) == SQLITE_ROW {
            lastInsert = sqlite3_column_int(stmt, 0)
            print(lastInsert)
            saveTracks(lastInserted: lastInsert)
        }
         let workout = workoutSession(id: 12,startTime: date,endTime: date2,duration: time,distance: distance,sourLat: first.coordinate.latitude,sourLong: first.coordinate.longitude,destLat: last.coordinate.latitude,destLong: last.coordinate.longitude)
        saveWorkoutToHealthKit(workout)
        time=0;
        updateUI();
        metersLab.text = "0.00 metres"
        displayTrack()
        allLocations.removeAll()
        test = 0
        self.tabBarController?.selectedIndex = 3
        
    }
    
    func displayTrack(){
        var tracks : [Track] = []
        
        let first = allLocations.first
        let last = allLocations.last
        
        for location in allLocations{
            let track = Track(latitude: location.coordinate.latitude,longitude: location.coordinate.longitude)
            tracks.append(track)
        }
        let vc = self.tabBarController?.viewControllers![3] as! mapViewController
        vc.sourLat = (first?.coordinate.latitude)!
        vc.sourLong = (first?.coordinate.longitude)!
        vc.destLat = (last?.coordinate.latitude)!
        vc.destLong = (last?.coordinate.longitude)!
        vc.tracks = tracks
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
