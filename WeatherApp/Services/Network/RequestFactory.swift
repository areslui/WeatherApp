//
//  RequestFactory.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

final class RequestFactory {
  
  enum Method: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
  }
  
  static func request(_ method: Method, _ url: URL, _ parameters: [String : Any]? = nil) -> URLRequest {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    if let parameters = parameters {
      request.httpBody = parameters.percentEncoded()
    }
    return request
  }
}
