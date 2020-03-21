//
//  ParserHelper.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

final class ParserHelper {
  
  static func parse<T: Parsable>(data: Data, completion: (Result<T, ErrorResult>) -> Void) {
    
    do {
      if let dictionary = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] {

        switch T.parseObject(dictionary: dictionary) {
        case .Error(let error):
          completion(.Error(error))
          break
        case .Success(let newModel):
          completion(.Success(newModel))
          break
        }
      } else {
        completion(.Error(.parser(string: "Json data is not an array")))
      }
    } catch {
      completion(.Error(.parser(string: "Error while parsing json data")))
    }
  }
}
