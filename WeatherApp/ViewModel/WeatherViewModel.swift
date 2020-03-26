//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Ares on 22/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation
import CoreData

class WeatherViewModel {
  
  var apiService: WeatherApiService?
  var dataSource: WeatherDataSource?
  var errorHandling: ((ErrorResult?) -> Void)?
  let isLoading = Observable<Bool>(value: false)
  let isTableViewHidden = Observable<Bool>(value: false)
  
  init(dataSource: WeatherDataSource = WeatherDataSource(),
       apiService: WeatherApiService = WeatherApiService()) {
    self.dataSource = dataSource
    self.apiService = apiService
  }
  
  func fetchWeatherData(completion: @escaping (Bool) -> ()) {
    guard let service = apiService else {
      errorHandling?(.custom(string: "Sevice missing!!!"))
      return
    }
    isLoading.value = true
    isTableViewHidden.value = true
    
    service.getDataWith { [weak self] (result) in
      
      switch result {
        
      case .Success(let data):
        self?.clearData()
        self?.saveInCoreDataWith(data.weatherArray)
        completion(true)
        
      case .Error(let message):
        self?.errorHandling?(message)
        completion(false)
        debugPrint("\(type(of: self)): \(#function): \(message)")
      }
      self?.isLoading.value = false
      self?.isTableViewHidden.value = false
    }
  }
  
  func performFetch() {
    dataSource?.coreDataPerformFetch()
  }
  
  // MARK: - Data Process
  
  func saveInCoreDataWith(_ array: [[String : Any]]) {
    _ = array.map{ createPhotoEntityFrom($0) }
    dataSource?.saveDataWithViewContext()
    debugPrint(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
  }
  
  private func createPhotoEntityFrom(_ dataDict: [String : Any]) {
    dataSource?.getViewContext(completion: { (viewContext) in
      guard let context = viewContext else { return }
      if let weatherEntity = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: context) as? Weather {
        if let requestAry = dataDict["request"] as? [[String : Any]],
          let query = requestAry[0]["query"] as? String {
          weatherEntity.city = query
        }
        if let currentAry = dataDict["current_condition"] as? [[String : Any]],
          let temp_C = currentAry[0]["temp_C"] as? String,
          let humidity = currentAry[0]["humidity"] as? String,
          let imageAry = currentAry[0]["weatherIconUrl"] as? [Any],
          let imageDict = imageAry[0] as? [String : Any],
          let imageUrl = imageDict["value"] as? String {
            weatherEntity.temparature = temp_C
            weatherEntity.humidity = humidity
          
          guard let apiService = self.apiService else { return }
          let imageDownloader = ImageDownloader(imageUrl, apiService.imageSession)
          imageDownloader.startDownloadImage(completeDownload: { (imageData) in
            weatherEntity.imageData = imageData
          })
        }
      }
    })
  }
  
  private func clearData() {
    dataSource?.clearCoreData()
  }
}
