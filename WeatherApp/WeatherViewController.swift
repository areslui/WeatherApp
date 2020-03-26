//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import UIKit

class WeatherViewController: UIViewController {

  @IBOutlet weak var tableView: UITableView!
  var searchBarController = UISearchController(searchResultsController: nil)
  var filteredTableData = [String]()
  
  lazy var viewModel = WeatherViewModel()
  lazy var loadingView = ActivityView(loadingView: view)
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBarSetup()
  }

  private func searchBarSetup() {
    searchBarController.searchResultsUpdater = self
    searchBarController.obscuresBackgroundDuringPresentation = false
    searchBarController.searchBar.sizeToFit()
    tableView.tableHeaderView = searchBarController.searchBar
  }
  
  private func updateTableContent() {
    viewModel.performFetch()
    self.viewModel.fetchPhotoData(completion: { [weak self] (success) in
      if success {
        self?.reloadTableViewInMainThread()
      } else {
        debugPrint("\(type(of: self)): \(#function): fetch weather data failed!")
      }
    })
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
}

// MARK: - TableView Delegate and DataSource

extension WeatherViewController: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    print(filteredTableData[indexPath.row])
  }
}

extension WeatherViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return filteredTableData.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
    cell.textLabel?.text = filteredTableData[indexPath.row]
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
    tableView.reloadData()
  }
}
