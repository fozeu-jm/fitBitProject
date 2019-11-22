//
//  HealthKitSetupAssistant.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 21/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import Foundation
import HealthKit

class HealthKitSetupAssistant {
  
  private enum HealthkitSetupError: Error {
    case notAvailableOnDevice
    case dataTypeNotAvailable
  }
  
  class func authorizeHealthKit(completion: @escaping (Bool, Error?) -> Swift.Void) {
    //1. Check to see if HealthKit Is Available on this device
    guard HKHealthStore.isHealthDataAvailable() else {
        completion(false, HealthkitSetupError.notAvailableOnDevice)
        return
    }
    

    //2. Prepare the data types that will interact with HealthKit
    guard  let distanceWalkingRunning = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning) else {

            completion(false, HealthkitSetupError.dataTypeNotAvailable)
            return
    }

    //3. Prepare a list of types you want HealthKit to read and write
    let healthKitTypesToWrite: Set<HKSampleType> = [
                                                    distanceWalkingRunning,
                                                    HKObjectType.workoutType()]

    let healthKitTypesToRead: Set<HKObjectType> = [
        distanceWalkingRunning,
        HKObjectType.workoutType()]


    //4. Request Authorization
    HKHealthStore().requestAuthorization(toShare: healthKitTypesToWrite,
                                         read: healthKitTypesToRead) { (success, error) in
                                            completion(success, error)
    }

  }
    
}
