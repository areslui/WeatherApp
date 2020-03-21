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
  
  static func parseObject(dictionary: [String : Any]) -> Result<WeatherData, ErrorResult> {
    if let ary = dictionary["items"] as? [[String : Any]] {
      
      let photoData = WeatherData(weatherArray: ary)
      return Result.Success(photoData)
    } else {
      return Result.Error(ErrorResult.parser(string: "Unable to parse"))
    }
  }
}
