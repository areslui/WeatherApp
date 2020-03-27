//
//  WeatherData.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

struct WeatherData {
  let weatherArray: [[String : Any]]
}

extension WeatherData: Parsable {
  
  static func parseObject(_ dictionary: [String : Any]) -> Result<WeatherData, ErrorResult> {
    if let ary = dictionary["data"] as? [String : Any] {
      let data = WeatherData(weatherArray: [ary])
      return Result.Success(data)
    } else {
      return Result.Error(ErrorResult.parser(string: "Unable to parse"))
    }
  }
}
