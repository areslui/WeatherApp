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
  
  lazy var viewModel = WeatherViewModel()
  lazy var loadingView = ActivityView(loadingView: view)
  
  var blockOperations = [BlockOperation]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBarSetup()
    viewModel.performFetch()
  }

  private func searchBarSetup() {
    searchBarController.searchResultsUpdater = self
    searchBarController.obscuresBackgroundDuringPresentation = false
    searchBarController.searchBar.sizeToFit()
    tableView.tableHeaderView = searchBarController.searchBar
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
  
  // MARK: - Deinit
  
  deinit {
    blockOperations.forEach { $0.cancel() }
    blockOperations.removeAll(keepingCapacity: false)
  }
}

// MARK: - TableView Delegate and DataSource

extension WeatherViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if searchBarController.isActive {
      loadingView.startAnimatingOnMainThread()
      viewModel.fetchWeatherData(filteredTableData[indexPath.row]) { [weak self] (success) in
        self?.loadingView.stopAnimatingOnMainThread()
        if success {
          self?.viewModel.performFetch()
          self?.reloadTableViewInMainThread()
        }
      }
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
      if let array = viewModel.dataSource?.countryList.filter({ searchPredicate.evaluate(with: $0) }) {
        filteredTableData = array
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
      let op = BlockOperation { [weak self] in
        self?.tableView.insertRows(at: [(newIndexPath as IndexPath)], with: .automatic)
      }
      blockOperations.append(op)
      
    case .update:
      guard let newIndexPath = newIndexPath else { return }
      let op = BlockOperation { [weak self] in
        self?.tableView.reloadRows(at: [(newIndexPath as IndexPath)], with: .automatic)
      }
      blockOperations.append(op)
      
    case .move:
      guard let indexPath = indexPath else { return }
      guard let newIndexPath = newIndexPath else { return }
      let op = BlockOperation { [weak self] in
        self?.tableView.moveRow(at: indexPath as IndexPath, to: newIndexPath as IndexPath)
      }
      blockOperations.append(op)
      
    case .delete:
      guard let indexPath = indexPath else { return }
      let op = BlockOperation { [weak self] in
        self?.tableView.deleteRows(at: [(indexPath as IndexPath)], with: .automatic)
      }
      blockOperations.append(op)
      
    @unknown default:
      fatalError()
    }
  }
  
  func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.performBatchUpdates({
      self.blockOperations.forEach { $0.start() }
    }, completion: { (finished) in
      self.blockOperations.removeAll(keepingCapacity: false)
    })
  }
  
  func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    blockOperations.removeAll(keepingCapacity: false)
  }
}
