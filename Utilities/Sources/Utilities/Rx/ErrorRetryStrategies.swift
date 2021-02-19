//
//  ErrorRetryStrategies.swift
//  Core
//
//  Created by Antonio Ivčec on 26/02/2020.
//

import Foundation
import RxSwift

/**
 A closure that receives an error observable and emits an empty element whenever it deems a subscription should retry.
 
 If the error should propagate further down the stream, the returned stream will emit an error.
 */
public typealias ErrorRetryStrategy = (Observable<Error>) -> Observable<Void>

/**
 Common error retry strategies.
 */
public struct ErrorRetryStrategies {
  
  /**
   Exponential backoff error retry strategy.
   
   Each subsequent subsription is delayed using exponential backoff.
   
   - parameter terminationCount: number of times the handler attempts to retry before terminating the stream with an error
   */
  public static func exponentialBackoff(terminationCount: Int = 3) -> ErrorRetryStrategy {
    return { errorObservable in
      errorObservable
        .enumerated()
        .flatMap { tuple -> Observable<Void> in
          let (index, error) = tuple
          
          if index < terminationCount {
            let delay = Int(truncating: pow(2, (index + 1)) as NSNumber)
            return Observable<Int>
              .timer(.seconds(delay), scheduler: MainScheduler.instance)
              .mapToVoid()
          } else {
            throw error
          }
      }
    }
  }
}
