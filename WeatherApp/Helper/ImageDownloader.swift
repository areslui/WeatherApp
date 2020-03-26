//
//  ImageDownloader.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation
import UIKit

class ImageDownloader {
  
  private let url: URL?
  private let session: WeatherApiSessionProtocol
  
  init(_ url: String?, _ session: WeatherApiSessionProtocol) {
    self.url = URL(string: url ?? "")
    self.session = session
  }
  
  func startDownloadImage(completeDownload: ((Data?) -> ())?) {
    guard let url = url else { return }
    let request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30)
    session.dataTask(with: request, completionHandler: { (data, response, error) in
      debugPrint("RESPONSE FROM API: \(String(describing: response))")
      if error != nil {
        debugPrint("ERROR LOADING IMAGES FROM URL: \(String(describing: error))")
        return
      }
      DispatchQueue.main.async {
        if let data = data {
          completeDownload?(data)
        }
      }
    }).resume()
  }
}
