//
//  RequestHandler.swift
//  WeatherApp
//
//  Created by Ares on 21/03/2020.
//  Copyright © 2020 haochen. All rights reserved.
//

import Foundation

protocol WeatherApiSessionProtocol: class {
  func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
  func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask
}

extension URLSession: WeatherApiSessionProtocol { }

protocol NetWorkResultProtocol {
  func networkResult<T: Parsable>(completion: @escaping ((Result<T, ErrorResult>) -> Void)) ->
  ((Result<Data, ErrorResult>) -> Void)
}

protocol Parsable {
  static func parseObject(_ dictionary: [String: Any]) -> Result<Self, ErrorResult>
}

