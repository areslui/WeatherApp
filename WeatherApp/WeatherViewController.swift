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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    searchBarSetup()
  }

  private func searchBarSetup() {
    searchBarController.delegate = self as? UISearchControllerDelegate
    searchBarController.searchBar.sizeToFit()
    tableView.tableHeaderView = searchBarController.searchBar
  }
  
  
}

extension WeatherViewController: UITableViewDelegate {
  
}

extension WeatherViewController: UITableViewDataSource {
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 10
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "weatherCell", for: indexPath)
    
    return cell
  }
}
