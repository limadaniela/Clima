//
//  WeatherData.swift
//  Clima
//
//  Created by Daniela Lima on 2022-07-17.
//

import Foundation

struct WeatherData: Codable {
    let name: String
    let main: Main
    //Weather property holds an array of weather items. This is why it's wrapped in square brackets
    let weather: [Weather]
}

//main is an object with 5 items, with properties: temp, pressure, humidity, temp_min, temp_max. This is why we need a Main struct
struct Main: Codable {
    let temp: Double
}

struct Weather: Codable {
    let id: Int
}
