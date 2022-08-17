//
//  WeatherModel.swift
//  Clima
//
//  Created by Daniela Lima on 2022-07-17.
//

import Foundation

struct WeatherModel {
    let conditionId: Int
    let cityName: String
    let temperature: Double
    
    //computed property to get temperature as a String with only one decimal place
    var temperatureString: String {
        return String(format: "%.1f", temperature)
    }
    
    //to figure out condition name based on the condition code of the weatherId
    //computed property is a property that calculates and returns a value, rather than just store it
    //we can use the conditionId property value to switch, and then check what condition it is to return this string which is going to be equal the conditionName
    var conditionName: String {
        switch conditionId {
        case 200...232:
            return "cloud.bolt"
        case 300...321:
            return "cloud.drizzle"
        case 500...531:
            return "cloud.rain"
        case 600...622:
            return "cloud.snow"
        case 701...781:
            return "cloud.fog"
        case 800:
            return "sun.max"
        case 801...804:
            return "cloud.bolt"
        default:
            return "cloud"
        }
    }
}




