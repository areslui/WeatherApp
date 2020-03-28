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
  lazy var locationString = ""
  
  init(dataSource: WeatherDataSource = WeatherDataSource(),
       apiService: WeatherApiService = WeatherApiService()) {
    self.dataSource = dataSource
    self.apiService = apiService
  }
  
  func fetchWeatherData(_ location: String) {
    guard let service = apiService else {
      errorHandling?(.custom(string: "Sevice missing!!!"))
      return
    }
    locationString = location
    isLoading.value = true
    
    service.getDataWith(locationString) { [weak self] (result) in
      
      switch result {
        
      case .Success(let data):
        self?.saveInCoreDataWith(data.weatherArray)
        self?.clearData()
        
      case .Error(let message):
        self?.errorHandling?(message)
        debugPrint("\(type(of: self)): \(#function): \(message)")
      }
      self?.isLoading.value = false
    }
  }
  
  func performFetch() {
    dataSource?.coreDataPerformFetch()
  }
  
  // MARK: - Data Process
  
  func saveInCoreDataWith(_ array: [[String : Any]]) {
    _ = array.map{ createWeatherEntityFrom($0) }
    dataSource?.saveDataWithViewContext()
    debugPrint("\(type(of: self)): \(#function): core data db path =", FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))
  }
  
  private func createWeatherEntityFrom(_ dataDict: [String : Any]) {
    dataSource?.getViewContext(completion: { (viewContext) in
      guard let context = viewContext else { return }
      if let weatherEntity = NSEntityDescription.insertNewObject(forEntityName: "Weather", into: context) as? Weather {
        weatherEntity.city = self.locationString
        if let currentAry = dataDict["current_condition"] as? [[String : Any]],
          let temp_C = currentAry[0]["temp_C"] as? String,
          let humidity = currentAry[0]["humidity"] as? String,
          let imageAry = currentAry[0]["weatherIconUrl"] as? [Any],
          let imageDict = imageAry[0] as? [String : Any],
          let imageUrl = imageDict["value"] as? String,
          let weatherAry = currentAry[0]["weatherDesc"] as? [Any],
          let weatherDict = weatherAry[0] as? [String : Any],
          let weather = weatherDict["value"] as? String {
          weatherEntity.temparature = temp_C
          weatherEntity.humidity = humidity
          weatherEntity.weather = weather
          weatherEntity.date = Date()
          
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
