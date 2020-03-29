//
//  FetchDataController.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import UIKit
import CoreData

struct FetchDataController {
  
  lazy var fetchHandler: NSFetchedResultsController<NSFetchRequestResult>? = {
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: String(describing: Weather.self))
    
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
    guard let viewContext = (UIApplication.shared.delegate as? AppDelegate)?.persistentContainer.viewContext else {
      return NSFetchedResultsController()
    }
    let dataFetchResultController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: viewContext, sectionNameKeyPath: nil, cacheName: nil)
    
    return dataFetchResultController
  }()
}
