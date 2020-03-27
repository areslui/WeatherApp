//
//  ActivityView.swift
//  WeatherApp
//
//  Created by Lu Hao-Chen on 26/3/20.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation
import UIKit

class ActivityView {
  
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
  var obsecuresView = UIView()
  
  init(loadingView: UIView) {
    self.loadingView = loadingView
  }
  
  private func addObsecuresView() {
    obsecuresView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
    obsecuresView.translatesAutoresizingMaskIntoConstraints = false
    loadingView.addSubview(obsecuresView)
    NSLayoutConstraint.activate([
      obsecuresView.topAnchor.constraint(equalTo: loadingView.topAnchor),
      obsecuresView.leftAnchor.constraint(equalTo: loadingView.leftAnchor),
      obsecuresView.bottomAnchor.constraint(equalTo: loadingView.bottomAnchor),
      obsecuresView.rightAnchor.constraint(equalTo: loadingView.rightAnchor)
    ])
  }
  
  func startAnimatingOnMainThread() {
    if Thread.isMainThread {
      addObsecuresView()
      loadingIdicator.startAnimating()
    } else {
      DispatchQueue.main.async {
        self.addObsecuresView()
        self.loadingIdicator.startAnimating()
      }
    }
  }
  
  func stopAnimatingOnMainThread() {
    if Thread.isMainThread {
      loadingIdicator.stopAnimating()
      obsecuresView.removeFromSuperview()
    } else {
      DispatchQueue.main.async {
        self.loadingIdicator.stopAnimating()
        self.obsecuresView.removeFromSuperview()
      }
    }
  }
}
