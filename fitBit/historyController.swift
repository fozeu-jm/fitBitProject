//
//  TableViewController.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 20/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import UIKit
import SQLite3

class historyController: UITableViewController {
    
    //@IBOutlet var tableView2: UITableView!
    var db : OpaquePointer?
    var sessions: [workoutSession] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        super.tableView.delegate = self
        super.tableView.dataSource = self
        
        loadDB()
        sessions = createArray()
    
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func loadDB(){
        let fileUrl = try!
            FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("fitbit.sqlite")
        
        if sqlite3_open(fileUrl.path, &db) != SQLITE_OK{
            print("Error opening file")
        }else{
           // print("Database connected")
        }
        
    }
    
    func createArray() -> [workoutSession] {
        var tempSessions: [workoutSession] = []
        
        var stmt2 : OpaquePointer?
        let select = "SELECT * FROM fitBit"
        
        if sqlite3_prepare(db, select, -1, &stmt2, nil) == SQLITE_OK {
            while sqlite3_step(stmt2) == SQLITE_ROW {
                
                //print("Je reviens sur les slides")
                
                let date = UnsafePointer<UInt8>(sqlite3_column_text(stmt2, 1))!
                let begin = String(cString: date)
                
                let date2 = UnsafePointer<UInt8>(sqlite3_column_text(stmt2, 2))!
                let end = String(cString: date2)
                
                let duration = Int(sqlite3_column_int(stmt2, 3))
                let distance = sqlite3_column_double(stmt2, 4)
                let sourlat = sqlite3_column_double(stmt2, 5)
                let sourlong = sqlite3_column_double(stmt2, 6)
                let destlat = sqlite3_column_double(stmt2, 7)
                let destlong = sqlite3_column_double(stmt2, 8)
                
                let session = workoutSession(startTime: begin, endTime: end, duration: duration, distance: distance, sourLat: sourlat, sourLong: sourlong, destLat: destlat, destLong: destlong)
                tempSessions.append(session)
            }
        }else{
            print(String.init(cString: sqlite3_errmsg(db)))
        }
        
        return tempSessions
    }
    
    
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return sessions.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CGFloat(58)
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let session = sessions[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "sessionCell") as! sessionCell
        cell.setSessionCell(session: session)
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section:Int) -> String?
    {
      return "Students"
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        viewDidLoad()
        super.tableView.reloadData()
    }
    

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
