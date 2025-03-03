//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import XCTest
@testable import WeatherApp

class WeatherAppServiceTests: XCTestCase {
  
  // system under test
  var sut: URLSession!
  
  override func setUp() {
    super.setUp()
    sut = URLSession(configuration: .default)
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  // Asynchronous test: success fast, failure slow
  func testSucessServiceCall() {
    let url = URL(string: "https://api.worldweatheronline.com/premium/v1/weather.ashx")
    
    // given
    let postParameters = ["key": "d0db1305b6964712bf630042202103", "q": "New+York"]
    let request = RequestFactory.request(.POST, url!, postParameters)
    let promise = expectation(description: "Status code: 200")
    
    // when
    let dataTask = sut.dataTask(with: request) { (data, response, error) in
      if let error = error {
        XCTFail("Error: \(error.localizedDescription)")
      } else if let statusCode = (response as? HTTPURLResponse)?.statusCode {
        if statusCode == 200 {
          promise.fulfill()
        } else {
          XCTFail("Status code: \(statusCode)")
        }
      }
    }
    dataTask.resume()
    // then
    wait(for: [promise], timeout: 5)
  }
  
  // Asynchronous test: faster fail
  func testCallCompletes() {
    // given
    let url = URL(string: "https://api.worldweatheronline.com/premium/v1/weather.ashx")
    let postParameters = ["key": "d0db1305b6964712bf630042202103", "q": "New+York"]
    let request = RequestFactory.request(.POST, url!, postParameters)
    let promise = expectation(description: "Completion handler invoked")
    var statusCode: Int?
    var responseError: Error?
    
    // when
    let dataTask = sut.dataTask(with: request) { data, response, error in
      statusCode = (response as? HTTPURLResponse)?.statusCode
      responseError = error
      promise.fulfill()
    }
    dataTask.resume()
    wait(for: [promise], timeout: 5)
    
    // then
    XCTAssertNil(responseError)
    XCTAssertEqual(statusCode, 200)
  }
}
