//
//  WorkoutDataStore.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 22/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import Foundation
import HealthKit

class WorkoutDataStore {
  
    class func loadPrancerciseWorkouts(completion: @escaping (([HKWorkout]?, Error?) -> Swift.Void)){
        
      //1. Get all workouts with the "Other" activity type.
     // let workoutPredicate = HKQuery.predicateForWorkouts(with: .other)
        
      //2. Get all workouts that only came from this app.
      let sourcePredicate = HKQuery.predicateForObjects(from: HKSource.default())

      //3. Combine the predicates into a single predicate.
      //let compound = NSCompoundPredicate(andPredicateWithSubpredicates: [workoutPredicate,sourcePredicate])
        
      //let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate,ascending: true)
            
      let query = HKSampleQuery(sampleType: HKObjectType.workoutType(),
                                predicate: sourcePredicate,
                                limit: 0,
                                sortDescriptors: nil) { (query, samples, error) in

        DispatchQueue.main.async {
            
          //4. Cast the samples as HKWorkout
          guard let samples = samples as? [HKWorkout],
                error == nil else {
              completion(nil, error)
              return
          }
            
          completion(samples, nil)
        }
      }
        
      HKHealthStore().execute(query)
    }
  
}
