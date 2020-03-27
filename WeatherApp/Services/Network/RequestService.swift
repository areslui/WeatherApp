//
//  RequestService.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

final class RequestService {
  
  func loadData(_ urlString: String,
                _ location: String,
                _ apiKey: String,
                _ session: WeatherApiSessionProtocol,
                completion: @escaping (Result<Data, ErrorResult>) -> Void) -> URLSessionTask? {
    
    guard let url = URL(string: urlString) else {
      completion(.Error(.network(string: "Wrong url format")))
      return nil
    }
    var postDict = [String : Any]()
    postDict["key"] = apiKey
    postDict["date"] = "today"
    postDict["q"] = location.replacingOccurrences(of: " ", with: "+")
    postDict["format"] = "json"
    var request = RequestFactory.request(.POST, url, postDict)
    
    InternetMonitor().checkInternetConnection { (result) in
      switch result {
      case .Success(_):
        debugPrint("\(type(of: self)): \(#function): has internet connection")
        break
      case .Error(let error):
        completion(.Error(.network(string: "no internet!" + error.localizedDescription)))
        request.cachePolicy = .returnCacheDataDontLoad
        return
      }
    }
    
    let task = session.dataTask(with: request) { (data, response, error) in
      if let error = error {
        completion(.Error(.network(string: "An error occured during request :" + error.localizedDescription)))
        return
      }
      
      if let data = data {
        completion(.Success(data))
      }
    }
    task.resume()
    return task
  }
}
