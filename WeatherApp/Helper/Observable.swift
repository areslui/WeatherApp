//
//  Observable.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

class Observable<T> {
  var value: T {
    didSet {
      DispatchQueue.main.async {
        self.valueChanged?(self.value)
      }
    }
  }
  
  private var valueChanged: ((T) -> Void)?
  
  init(value: T) {
    self.value = value
  }
  
  /// Add closure as an observer and trigger the closure imeediately if fireNow = true
  func addObserver(fireNow: Bool = true, _ onChange: ((T) -> Void)?) {
    valueChanged = onChange
    if fireNow {
      onChange?(value)
    }
  }
  
  func removeObserver() {
    valueChanged = nil
  }
}
