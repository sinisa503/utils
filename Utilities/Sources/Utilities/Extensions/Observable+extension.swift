//
//  Observable+extension.swift
//  Core
//
//  Created by Antonio Ivčec on 26/02/2020.
//

import Foundation
import RxSwift
import RxCocoa

public extension SharedSequenceConvertibleType {
  
  func mapToVoid() -> SharedSequence<SharingStrategy, Void> {
    return map { _ in }
  }
  
  func unwrap<T>() -> SharedSequence<SharingStrategy, T> where Element == T? {
    return filter { $0 != nil }.map { $0! }
  }
}

public extension ObservableConvertibleType {
  
  func asDriverLogError(_ file: StaticString = #file, _ line: UInt = #line) -> SharedSequence<DriverSharingStrategy, Element> {
    return asDriver(onErrorRecover: {
      debugPrint("Error:", $0, " in file:", file, " atLine:", line)
      return .empty()
    })
  }
  
  func asSignalLogError(_ file: StaticString = #file, _ line: UInt = #line) -> SharedSequence<SignalSharingStrategy, Element> {
    return asSignal(onErrorRecover: {
      debugPrint("Error:", $0, " in file:", file, " atLine:", line)
      return .empty()
    })
  }
}

public extension ObservableType {
  
  func catchErrorJustComplete() -> Observable<Element> {
    return catchError { _ in Observable.empty() }
  }
  
  func asDriverOnErrorJustComplete() -> Driver<Element> {
    return asDriver { _ in Driver.empty() }
  }
  
  func asSignalOnErrorJustComplete() -> Signal<Element> {
    return asSignal { _ in Signal.empty() }
  }
  
  func mapToVoid() -> Observable<Void> {
    return map { _ in }
  }
  
  func unwrap<T>() -> Observable<T> where Element == T? {
    return filter { $0 != nil }.map { $0! }
  }
  
  func distinctUntilChanged<T>(_ keyPath: KeyPath<Element, T>) -> Observable<Element> where T: Equatable {
    return distinctUntilChanged({ $0[keyPath: keyPath]}, comparer: ==)
  }
  
  func compactMap<Result>(_ keyPath: KeyPath<Element, Result?>) -> Observable<Result> {
    return compactMap { $0[keyPath: keyPath] }
  }
  
  func map<Result>(_ keyPath: KeyPath<Element, Result>) -> Observable<Result> {
    return map { $0[keyPath: keyPath] }
  }
  
  func log() -> Observable<Self.Element> {
    return self.do(
      onNext: { debugPrint("Receive element -  ", $0) },
      onError: { debugPrint("Receive error - ", $0) },
      onCompleted: { debugPrint("Receive completed") },
      onSubscribe: { debugPrint("Subscribe") },
      onDispose: { debugPrint("Dispose") })
  }
}

public extension SharedSequence {
  
  func distinctUntilChanged<T>(_ keyPath: KeyPath<Element, T>) -> SharedSequence<SharingStrategy, Element> where T: Equatable {
    return distinctUntilChanged({ $0[keyPath: keyPath]}, comparer: ==)
  }
  
  func compactMap<Result>(_ keyPath: KeyPath<Element, Result?>) -> SharedSequence<SharingStrategy, Result> {
    return map { $0[keyPath: keyPath] }.unwrap()
  }
  
  func map<Result>(_ keyPath: KeyPath<Element, Result>) -> SharedSequence<SharingStrategy, Result> {
    return map { $0[keyPath: keyPath] }
  }
  
  func log() -> SharedSequence {
    return self.do(
      onNext: { debugPrint("Receive element -  ", $0) },
      onCompleted: { debugPrint("Receive completed") },
      onSubscribe: { debugPrint("Subscribe") },
      onDispose: { debugPrint("Dispose") })
  }
}
