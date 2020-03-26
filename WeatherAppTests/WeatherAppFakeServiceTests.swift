//
//  WeatherAppFakeServiceTests.swift
//  WeatherAppTests
//
//  Created by Ares on 22/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import XCTest
@testable import WeatherApp

class WeatherAppFakeServiceTests: XCTestCase {
  
  var sut: WeatherViewModel!
  
  override func setUp() {
    super.setUp()
    sut = WeatherViewModel()
    let testBundle = Bundle(for: type(of: self))
    let path = testBundle.path(forResource: "SGData", ofType: "json")
    let data = try? Data(contentsOf: URL(fileURLWithPath: path ?? ""), options: .alwaysMapped)
    
    let url = URL(string: "https://api.worldweatheronline.com/premium/v1/weather.ashx")
    let urlResponse = HTTPURLResponse(url: url!, statusCode: 200, httpVersion: nil, headerFields: nil)
    let sessionMock = URLSessionMock(data: data, response: urlResponse, error: nil)
    sut.apiService?.defaultSession = sessionMock
    
    let imageUrl = URL(string: "http://cdn.worldweatheronline.net/images/wsymbols01_png_64/wsymbol_0004_black_low_cloud.png")
    let imageUrlResponse = HTTPURLResponse(url: imageUrl!, statusCode: 200, httpVersion: nil, headerFields: nil)
    let imagePath = testBundle.path(forResource: "cloud", ofType: "png")
    let imageMockData = try? Data(contentsOf: URL(fileURLWithPath: imagePath ?? ""), options: .alwaysMapped)
    let imageSessionMock = URLSessionMock(data: imageMockData, response: imageUrlResponse, error: nil)
    sut.apiService?.imageSession = imageSessionMock
  }
  
  override func tearDown() {
    sut = nil
    super.tearDown()
  }
  
  func testUpdateResultsParsesData() {
    // given
    let promise = expectation(description: "query = Singapore, Singapore")
    sut.dataSource?.clearCoreData(true)
    sut.dataSource?.coreDataPerformFetch()
    XCTAssertEqual(sut.dataSource?.fetchDataController?.fetchHandler?.sections?.first?.numberOfObjects, 0, "should be empty before task runs")
    
    // when
    sut.apiService?.getDataWith(completion: { [weak self] (result) in
      switch result {
      case .Success(let data):
        let dataDict = data.weatherArray[0]
        if let requestAry = dataDict["request"] as? [[String : Any]],
          let query = requestAry[0]["query"] as? String,
          query == "Singapore, Singapore" {
          self?.sut.saveInCoreDataWith(data.weatherArray)
          promise.fulfill()
        }
        break
        
      case .Error(let error):
        debugPrint(error.localizedDescription)
        break
      }
    })
    wait(for: [promise], timeout: 5)
    // then
    sut.dataSource?.coreDataPerformFetch()
    XCTAssertEqual(sut.dataSource?.fetchDataController?.fetchHandler?.sections?.first?.numberOfObjects, 1, "should only got 1 item in db")
    sut.dataSource?.clearCoreData(true)
  }
  
  func testPerformanceExample() {
    // This is an example of a performance test case.
    self.measure {
      // Put the code you want to measure the time of here.
    }
  }
  
}
