//
//  WeatherManager.swift
//  Clima
//
//  Created by Daniela Lima on 2022-07-13.
//

import Foundation
import CoreLocation

//by convention, create the protocol in the same file as the class that will use the protocol
protocol WeatherManagerDelegate {
    //input of this func is weather and it has to be of type WeatherModel
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel)
    func didFailWithError(error: Error)
}

struct WeatherManager {
    let weatherURL =
    //get Open Weather Map API Key: https://openweathermap.org/appid
    "https://api.openweathermap.org/data/2.5/weather?appid=KEY&units=metric"
    
    //if some class or struct set themselves as the delegaate, we would be able to call upon the delegate and tell it to update weather
    var delegate: WeatherManagerDelegate?
    
    //fetchWeather takes the cityName as an input
    func fetchWeather(cityName: String) {
        //"&q=" is to include cityName at the end of the weatherURL
        let urlString = "\(weatherURL)&q=\(cityName)"
        performRequest(with: urlString)
    }
    
    //fetchWeather takes lat and long to get the current weather data
    func fetchWeather(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        let urlString = "\(weatherURL)&lat=\(latitude)&lon=\(longitude)"
        performRequest(with: urlString)
    }
    
    // with performRequest we're able to perform the networking that fetches the live data from OpenWeather Map
    func performRequest(with urlString: String) {
        
        //1. Create a URL object
        //always initialise a Struct in Class with a set of parenthesis
        //this way of initialising url from string, creates an optional url. So we use "if let" to optionally bind the url that's created to a constant called url as long as it doesn't fail and doesn't end up being nill.
        if let url = URL(string: urlString) {
            
            //2. Create a URLSession
            //default configuration ends up creating a url session object which is effectivelly like our browser (it's the thing that can perform the networking)
            let  session = URLSession(configuration: .default)
            
            //3. Give URLSession a task
            //we can tap into a session that we've just created and give a data task with url and completion handler (creates a task that retrieves the content of the specified URL, then calls a handler upon completion)
            //the task retrieves the content of the specified URL, then calls a handler upon completion, which is going to pass an optinal data, response and error
            //here we use closure format in completionhandler
            let task = session.dataTask(with: url) { (data, response, error) in
                //func to be used as input on the completionHandler method
                //there's nothing after return keyword, which means exit out of this function and don't continue. If there's an error, it will not do anything else
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    return
                }
                
                //inside a closure, the rule is that we must add self if we're calling a method from the current class.
                if let safeData = data {
                    if let weather = self.parseJSON(weatherData: safeData) { //to unwrap the weather object that get back from parseJSON
                        self.delegate?.didUpdateWeather(self, weather: weather)
                    }
                }
            }
            //4. Start the task
            //we call it resume because newly-initialized tasks begin in a suspended state, so you need to call this method to start the task.
            task.resume()
        }
    }
    //WeatherData is a data type that we're using to decode that conforms to the decoder protocol
    //to specify the WeatherData type reather than the WeatherData object, we have do add a ".self" to reference the type
    //the data that we want to endode is going to be passed in as the last input "from: weatherData"
    //the decode method is marked with throws keyword, so if something goes wrong, it can throw out an error. For that, we include a try keyword and wrap it inside a "do" block. And if throws an error, we have a catch block that can catch the error
    //to set something as nil, WeatherModel as to become an optional
    func parseJSON(weatherData: Data)  -> WeatherModel? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(WeatherData.self, from: weatherData)
            let id = decodedData.weather[0].id
            let temp = decodedData.main.temp
            let name = decodedData.name
            
            //weather object from WeatherModel
            let weather = WeatherModel(conditionId: id, cityName: name, temperature: temp)
            return weather
        } catch {
            delegate?.didFailWithError(error: error)
            return nil
        }
    }
}
