//
//  workoutSession.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 20/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import Foundation

class workoutSession {
    
    var id : Int32
    var startTime: String
    var endTime: String
    var duration: Int
    var distance: Double
    var sourLat: Double
    var sourLong: Double
    var destLat: Double
    var destLong: Double
    
    init(id : Int32, startTime: String,endTime: String, duration: Int, distance: Double, sourLat: Double, sourLong: Double, destLat: Double, destLong: Double) {
        
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.distance = distance
        self.sourLat = sourLat
        self.sourLong = sourLong
        self.destLat = destLat
        self.destLong = destLong
        
    }
    
}
