//
//  WeatherAppUITests.swift
//  WeatherAppUITests
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import XCTest

class WeatherAppUITests: XCTestCase {
  
  var app: XCUIApplication!
  
  override func setUp() {
    continueAfterFailure = false
    app = XCUIApplication()
    app.launch()
  }
  
  func testUIFlow() {
    let app = XCUIApplication()
    let searchField = app.searchFields["Search"]
    searchField.tap()
    searchField.typeText("Taipei")
    app.searchFields["Search"].buttons["Clear text"].tap()
    searchField.typeText("Singapore")
    app.tables.staticTexts["Singapore"].tap()
    app.navigationBars["WeatherApp.DetailView"].buttons["Search"].tap()
  }
}
