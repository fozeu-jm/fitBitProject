//
//  HKCell.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 21/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import UIKit

class HKCell: UITableViewCell {

    @IBOutlet weak var dateLab: UILabel!
    @IBOutlet weak var distanceLab: UILabel!
    
    @IBOutlet weak var hourLab: UILabel!
    @IBOutlet weak var minslab: UILabel!
    @IBOutlet weak var secLab: UILabel!
    
    
    func setSessionCell(session : workoutSession){
           
           let df = DateFormatter()
           df.dateFormat = "yyyy-MM-dd HH:mm:ss"
           
           let date = df.date(from: session.startTime)
           
           let df2 = DateFormatter()
           df2.dateFormat = "MMM d, yyyy HH:mm"
           
           let final = df2.string(from: date!)
           
           
           dateLab.text = final+" - Footing"
           distanceLab.text = String(format: "%.8f",session.distance)+" m"
          
          var hours: Int
          var min: Int
          var sec: Int
          let time = session.duration
          
          hours = time / (60*60)
          min = (time/60)%60
          sec = time % 60
          
          hourLab.text = String(hours)
          if(min < 10){
              minslab.text = "0"+String(min)
          }else{
              minslab.text = String(min)
          }
          if(sec < 10){
              secLab.text = "0"+String(sec)
          }else{
              secLab.text = String(sec)
          }
       }
   

}
