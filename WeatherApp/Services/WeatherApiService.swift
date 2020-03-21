//
//  WeatherApiService.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

final class WeatherApiService: WeatherApiServiceProtocol, NetWorkResultProtocol {
  
  private lazy var endPoint: String = {
    return "https://api.worldweatheronline.com/premium/v1/weather.ashx"
  }()
  
  private lazy var apiKey: String = {
    return "d0db1305b6964712bf630042202103"
  }()
  
  private var task: URLSessionTask?
  
  func getDataWith(completion: @escaping (Result<WeatherData, ErrorResult>) -> Void) {
    cancelFetch()
    task = RequestService().loadData(endPoint,
                                     "",
                                     apiKey,
                                     completion: networkResult(completion: completion))
  }
  
  func networkResult<T>(completion: @escaping ((Result<T, ErrorResult>) -> Void)) -> ((Result<Data, ErrorResult>) -> Void) where T : Parsable {
    
    return { dataResult in
      DispatchQueue.global(qos: .background).async(execute: {
        switch dataResult {
        case .Success(let data) :
          ParserHelper.parse(data: data, completion: completion)
          break
        case .Error(let error) :
          debugPrint("\(type(of: self)): \(#function): Network error \(error)")
          completion(.Error(.network(string: "Network error " + error.localizedDescription)))
          break
        }
      })
    }
  }
  
  private func cancelFetch() {
    if let task = task {
      task.cancel()
    }
    task = nil
  }
}
