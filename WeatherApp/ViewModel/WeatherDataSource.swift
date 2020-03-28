//
//  WeatherDataSource.swift
//  WeatherApp
//
//  Created by Ares on 22/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import CoreData
import UIKit

class WeatherDataSource {
  
  var fetchDataController: FetchDataController?
  
  lazy var cityList: [String?] = {
    return TimeZone.knownTimeZoneIdentifiers.map { $0.components(separatedBy: "/").last?.replacingOccurrences(of: "_", with: " ") }
  }()
  
  init(_ fetchDataController: FetchDataController = FetchDataController()) {
    self.fetchDataController = fetchDataController
  }
  
  func getViewContext(completion: @escaping (_ viewContext: NSManagedObjectContext?) -> ()) {
    if Thread.isMainThread {
      completion((UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
    } else {
      DispatchQueue.main.async {
        completion((UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext)
      }
    }
  }
  
  func saveDataWithViewContext() {
    if Thread.isMainThread {
      saveContextInMainThread()
    } else {
      DispatchQueue.main.async {
        self.saveContextInMainThread()
      }
    }
  }
  
  func saveContextInMainThread() {
    do {
      try (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext.save()
    } catch let error {
      debugPrint("\(type(of: self)): \(#function): \(error)")
    }
  }
  
  func clearCoreData(_ isClearAll: Bool? = nil) {
    getViewContext(completion: { (viewContext) in
      guard let context = viewContext,
        let fetchRequest = self.fetchDataController?.fetchHandler?.fetchRequest else {
          return
      }
      do {
        if let isClearAll = isClearAll,
          isClearAll {
          let fetchResults = try context.fetch(fetchRequest) as? [NSManagedObject]
          _ = fetchResults.map{ $0.map{ context.delete($0) } }
        } else {
          if let fetchResults = try context.fetch(fetchRequest) as? [NSManagedObject],
            let lastObj = fetchResults.last,
            fetchResults.count > 10 {
            context.delete(lastObj)
          }
        }
        self.saveDataWithViewContext()
      } catch {
        debugPrint("\(type(of: self)): \(#function): ERROR DELETING : \(error)")
      }
    })
  }
  
  func coreDataPerformFetch() {
    do {
      try fetchDataController?.fetchHandler?.performFetch()
    } catch (let error) {
      debugPrint("\(type(of: self)): \(#function): \(error.localizedDescription)")
    }
  }
  
  func coreDatafetchObjectAtIndex(_ index: IndexPath) -> Weather? {
    guard let weather = fetchDataController?.fetchHandler?.object(at: index) as? Weather else {
      return nil
    }
    return weather
  }
  
  func coreDataFetchCountForView() -> Int? {
    return fetchDataController?.fetchHandler?.sections?.first?.numberOfObjects
  }
}
