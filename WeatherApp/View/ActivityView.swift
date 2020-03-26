//
//  ActivityView.swift
//  WeatherApp
//
//  Created by Lu Hao-Chen on 26/3/20.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation
import UIKit

struct ActivityView {
  
  lazy var loadingIdicator: UIActivityIndicatorView = {
    let indicator = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
    indicator.translatesAutoresizingMaskIntoConstraints = false
    indicator.hidesWhenStopped = true
    loadingView.addSubview(indicator)
    NSLayoutConstraint.activate([
      indicator.centerXAnchor.constraint(equalTo: loadingView.centerXAnchor),
      indicator.centerYAnchor.constraint(equalTo: loadingView.centerYAnchor)
    ])
    return indicator
  }()
  
  private var loadingView: UIView
  
  init(loadingView: UIView) {
    self.loadingView = loadingView
  }
}
