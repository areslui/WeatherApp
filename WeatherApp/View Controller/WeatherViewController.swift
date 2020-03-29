//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import UIKit
import CoreData
import CoreLocation

class WeatherViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  var searchBarController = UISearchController(searchResultsController: nil)
  var filteredTableData = [String]()
  
  var viewModel = WeatherViewModel()
  lazy var loadingView = ActivityView(loadingView: view)
  lazy var tappedObj = Weather()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBarSetup()
    viewModel.performFetch()
    viewModel.dataSource?.fetchDataController?.fetchHandler?.delegate = self
    initBinding()
  }
  
  private func searchBarSetup() {
    searchBarController.searchResultsUpdater = self
    searchBarController.obscuresBackgroundDuringPresentation = false
    searchBarController.searchBar.sizeToFit()
    tableView.tableHeaderView = searchBarController.searchBar
  }
  
  private func initBinding() {
    viewModel.isLoading.addObserver { [weak self] (isLoading) in
      if isLoading {
        self?.loadingView.startAnimatingOnMainThread()
      } else {
        self?.loadingView.stopAnimatingOnMainThread()
      }
    }
  }
  
  private func reloadTableViewInMainThread() {
    if Thread.isMainThread {
      self.tableView.reloadData()
    } else {
      DispatchQueue.main.async {
        self.tableView.reloadData()
      }
    }
  }
  
  private func performSegueInMainThread(_ id: String) {
    if Thread.isMainThread {
      performSegue(withIdentifier: id, sender: self)
    } else {
      DispatchQueue.main.async {
        self.performSegue(withIdentifier: id, sender: self)
      }
    }
  }
  
  // MARK: - Navigation
  
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == "showDetailView" {
      guard let vc = segue.destination as? DetailViewController else { return }
      vc.weatherObj = tappedObj
    }
  }
  
}

// MARK: - TableView Delegate and DataSource

extension WeatherViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if searchBarController.isActive {
      viewModel.fetchWeatherData(filteredTableData[indexPath.row], completion: { [weak self] (success) in
        if let self = self,
          success {
          self.viewModel.performFetch()
          guard let objs = self.viewModel.dataSource?.fetchDataController?.fetchHandler?.sections?.first?.objects,
            let typedObj = objs[0] as? Weather
            else {
              return
          }
          self.tappedObj = typedObj
          self.performSegueInMainThread("showDetailView")
        }
      })
    } else {
      guard let rowObj = viewModel.dataSource?.coreDatafetchObjectAtIndex(indexPath)
        else {
          return
      }
      tappedObj = rowObj
      self.performSegueInMainThread("showDetailView")
    }
  }
}

extension WeatherViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if searchBarController.isActive {
      return filteredTableData.count
    } else {
      guard let coreDataCount = viewModel.dataSource?.coreDataFetchCountForView() else {
        return 0
      }
      return coreDataCount
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
    
    if searchBarController.isActive {
      cell.textLabel?.text = filteredTableData[indexPath.row]
    } else {
      guard let weatherObj = viewModel.dataSource?.coreDatafetchObjectAtIndex(indexPath) else {
        return UITableViewCell()
      }
      cell.textLabel?.text = weatherObj.city
    }
    return cell
  }
}

// MARK: - SearchResults Delegate

extension WeatherViewController: UISearchResultsUpdating {
  
  func updateSearchResults(for searchController: UISearchController) {
    
    filteredTableData.removeAll(keepingCapacity: false)
    if let searchText = searchController.searchBar.text {
      let searchPredicate = NSPredicate(format: "SELF CONTAINS[c] %@", searchText)
      if let cityList = viewModel.dataSource?.cityList as? [String] {
        filteredTableData = cityList.filter({ searchPredicate.evaluate(with: $0) })
      }
    }
    reloadTableViewInMainThread()
  }
}

// MARK: - NSFetchedResultsControllerDelegate

extension WeatherViewController: NSFetchedResultsControllerDelegate {
  
  func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
    
    switch type {
      
    case .insert:
      guard let newIndexPath = newIndexPath else { return }
      self.tableView.insertRows(at: [newIndexPath], with: .automatic)
      
    case .update:
      guard let newIndexPath = newIndexPath else { return }
      self.tableView.reloadRows(at: [newIndexPath], with: .automatic)
      
    case .move:
      guard let indexPath = indexPath else { return }
      guard let newIndexPath = newIndexPath else { return }
      self.tableView.moveRow(at: indexPath, to: newIndexPath)
      
    case .delete:
      guard let indexPath = indexPath else { return }
      self.tableView.deleteRows(at: [indexPath], with: .automatic)
      
    @unknown default:
      fatalError()
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
  }
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    searchBarController.isActive = false
    tableView.beginUpdates()
  }
}
