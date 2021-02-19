//
//  Result+extension.swift
//  Utilities
//
//  Created by Antonio Ivčec on 09/03/2020.
//

import Foundation
import RxSwift

extension Result: ObservableConvertibleType {
  public typealias Element = Success
  
  public func asObservable() -> Observable<Success> {
    switch self {
    case .success(let success):
      return Observable.just(success)
    case .failure(let error):
      return Observable.error(error)
    }
  }
}
