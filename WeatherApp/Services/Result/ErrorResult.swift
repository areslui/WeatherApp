//
//  ErrorResult.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

enum ErrorResult: Error {
  case network(string: String)
  case parser(string: String)
  case custom(string: String)
  
  var value: String {
    switch self {
    case .network(string: let value):
      return value
    case .parser(string: let value):
      return value
    case let .custom(string: value):
      return value
    }
  }
}
