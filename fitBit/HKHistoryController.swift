//
//  HKVieweController.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 22/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import UIKit
import HealthKit

class HKHistoryController: UITableViewController {
    var sessions: [workoutSession] = []
    let healthkitStore = HKHealthStore()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        readSessions()
        super.tableView.delegate = self
        super.tableView.dataSource = self
        
        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    func readSessions(){
        WorkoutDataStore.loadPrancerciseWorkouts { ( collection, error) in
            
            for work in collection!{
                let id = 12
                let df = DateFormatter()
                df.dateFormat = "yyyy-MM-dd HH:mm:ss"
                let start = work.startDate
                let stop = work.endDate
                
                let begin = df.string(from: start)
                let end = df.string(from: stop)
                let duration = Int(work.duration)
                let distance : Double = (work.totalDistance?.doubleValue(for: HKUnit.meter()))!
                let session = workoutSession(id: Int32(id), startTime: begin, endTime: end, duration: duration, distance: distance, sourLat: 0, sourLong: 0, destLat: 0, destLong: 0)
                
                self.sessions.append(session)
                super.tableView.reloadData()
            }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print(self.sessions)
        return self.sessions.count //count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(58)
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("populate !")
        let session = sessions[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "HKCell") as! HKCell
        cell.setSessionCell(session: session)
        return cell
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
