//
//  WeatherApiService.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

final class WeatherApiService {
  
  private lazy var endPoint: String = {
    return "https://api.worldweatheronline.com/premium/v1/weather.ashx"
  }()
  
  private lazy var apiKey: String = {
    return "d0db1305b6964712bf630042202103"
  }()
  
  var defaultSession: WeatherApiSessionProtocol = URLSession(configuration: .default)
  var imageSession: WeatherApiSessionProtocol = URLSession(configuration: .default)
  private var dataTask: URLSessionDataTask?
  
  func getDataWith(completion: @escaping (Result<WeatherData, ErrorResult>) -> Void) {
    cancelFetch()
    dataTask = RequestService().loadData(endPoint,
                                     "",
                                     apiKey,
                                     defaultSession,
                                     completion: networkResult(completion: completion)) as? URLSessionDataTask
  }
  
  private func cancelFetch() {
    if let dataTask = dataTask {
      dataTask.cancel()
    }
    dataTask = nil
  }
}

extension WeatherApiService: NetWorkResultProtocol {
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
}
