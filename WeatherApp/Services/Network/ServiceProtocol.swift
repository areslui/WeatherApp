//
//  RequestHandler.swift
//  WeatherApp
//
//  Created by Ares on 21/03/2020.
//  Copyright © 2020 haochen. All rights reserved.
//

import Foundation

protocol WeatherApiServiceProtocol: class {
  func getDataWith(completion: @escaping (Result<PhotoData, ErrorResult>) -> Void)
}

protocol NetWorkResultProtocol {
  func networkResult<T: Parsable>(completion: @escaping ((Result<T, ErrorResult>) -> Void)) ->
  ((Result<Data, ErrorResult>) -> Void)
}

protocol Parsable {
  static func parseObject(dictionary: [String: Any]) -> Result<Self, ErrorResult>
}

