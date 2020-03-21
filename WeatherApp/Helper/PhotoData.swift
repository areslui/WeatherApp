//
//  PhotoData.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

struct PhotoData {
  let photoArray: [[String : Any]]
}

extension PhotoData: Parsable {
  
  static func parseObject(dictionary: [String : Any]) -> Result<PhotoData, ErrorResult> {
    if let ary = dictionary["items"] as? [[String : Any]] {
      
      let photoData = PhotoData(photoArray: ary)
      return Result.Success(photoData)
    } else {
      return Result.Error(ErrorResult.parser(string: "Unable to parse"))
    }
  }
}
