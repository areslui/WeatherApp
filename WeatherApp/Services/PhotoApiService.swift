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
    return "https://api.flickr.com/services/feeds/photos_public.gne?format=json&tags=cars&nojsoncallback=1#"
  }()
  
  private var task: URLSessionTask?
  
  func getDataWith(completion: @escaping (Result<PhotoData, ErrorResult>) -> Void) {
    cancelFetch()
    task = RequestService().loadData(urlString: endPoint, completion: networkResult(completion: completion))
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
