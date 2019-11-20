//
//  sessionCell.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 20/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import UIKit

class sessionCell: UITableViewCell {
    
    @IBOutlet weak var dateLab: UILabel!
    @IBOutlet weak var distanceLab: UILabel!
    
    @IBOutlet weak var hourLab: UILabel!
    @IBOutlet weak var minsLab: UILabel!
    @IBOutlet weak var secLab: UILabel!
    @IBOutlet weak var sourLat: UILabel!
    @IBOutlet weak var sourLong: UILabel!
    @IBOutlet weak var destLat: UILabel!
    @IBOutlet weak var destLong: UILabel!
    
    func setSessionCell(session : workoutSession){
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let date = df.date(from: session.startTime)
        
        let df2 = DateFormatter()
        df2.dateFormat = "MMM d, yyyy HH:mm"
        
        let final = df2.string(from: date!)
        
        
        dateLab.text = final+" - Footing"
        distanceLab.text = String(format: "%.8f",session.distance)+" m"
        sourLat.text = String(session.sourLat)
        sourLong.text = String(session.sourLong)
        destLat.text = String(session.sourLat)
        destLong.text = String(session.destLong)
        
       var hours: Int
       var min: Int
       var sec: Int
       let time = session.duration
       
       hours = time / (60*60)
       min = (time/60)%60
       sec = time % 60
       
       hourLab.text = String(hours)
       if(min < 10){
           minsLab.text = "0"+String(min)
       }else{
           minsLab.text = String(min)
       }
       if(sec < 10){
           secLab.text = "0"+String(sec)
       }else{
           secLab.text = String(sec)
       }
    }
    
}
