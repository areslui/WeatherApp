//
//  Result.swift
//  WeatherApp
//
//  Created by Ares on 21/3/2020.
//  Copyright © 2020 Neo Studio. All rights reserved.
//

import Foundation

enum Result <T, E: Error> {
  case Success(T)
  case Error(E)
}
