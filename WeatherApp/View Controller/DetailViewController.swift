//
//  DetailViewController.swift
//  WeatherApp
//
//  Created by Ares on 28/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
  
  var weatherObj: Weather?
  @IBOutlet weak var cityName: UILabel!
  @IBOutlet weak var weather: UILabel!
  @IBOutlet weak var tempC: UILabel!
  @IBOutlet weak var weatherIcon: UIImageView!
  @IBOutlet weak var currentTime: UILabel!
  @IBOutlet weak var humidity: UILabel!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
  }
  
  private func setupUI() {
    guard let weatherObj = weatherObj else { return }
    cityName.text = weatherObj.city
    weather.text = weatherObj.weather
    if let tempC = weatherObj.temparature {
      self.tempC.text = tempC + "\u{00B0}C"
    }
    if let imageData = weatherObj.imageData {
      weatherIcon.image = UIImage.init(data: imageData)
    }
//    currentTime.text = weatherObj.date
    humidity.text = weatherObj.humidity
  }
}
