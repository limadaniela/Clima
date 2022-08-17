//
//  ViewController.swift
//  Clima
//
//  Created by Daniela Lima on 2022-07-05.
//

import UIKit
import CoreLocation

class WeatherViewController: UIViewController {

    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var searchTextField: UITextField!
    
    //we need this var so we can use WeatherManager in our WeatherViewController
    var weatherManager = WeatherManager()
    
    //object that is gonna be responsible for getting hold of current GPS location of the phone
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //to get hold of current GPS location, we have to trigger a permission request
        locationManager.requestWhenInUseAuthorization()
        
        //set the current Class (WeatherViewController) as the delegate, before reuqesting location. So, it will be able to respod when request location triggers this method
        locationManager.delegate = self
        
        //locationManager is going to trigger the delegate's didUpdateWeather
        locationManager.requestLocation()
        
        //set current class as the delegate
        weatherManager.delegate = self
        
        //the textField should report back to our ViewController. When the user interacts with the textField, then it will notify our ViewController on whats happening. We ensure this communication by setting the ViewContoller as the delegate.
        searchTextField.delegate = self
    }
    
    @IBAction func locationPressed(_ sender: UIButton) {
        locationManager.requestLocation()
    }
}

//MARK: - UITextFieldDelegate

//UITextFieldDelegate will allow our WeatherViewController to manage editing and validation of text in a textField
extension WeatherViewController: UITextFieldDelegate {

    
    @IBAction func searchPressed(_ sender: UIButton) {
        //it will tell the searchTextField that we're donne with editing and dismiss the keyboard
        searchTextField.endEditing(true)
        
        //to get hold of the text user typed in textField either pressing searchButton or "Go" button.
        //As it could be an empty String we force unwrapping.
        print(searchTextField.text!)
    }
    
    //asks the delegate if textField should process the pressing of the return button
    //return Bool that tells the textField whether it actually should process the return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //it will tell the searchTextField that we're donne with editing and can dismiss the keyboard
        searchTextField.endEditing(true)
        print(searchTextField.text!)
        return true
    }
    
    //textFieldShouldEndEditing is useful for doing some validation on what the user typed. E.g. if the textField is empty, then we're going to remind the user to write something (return false because we're not gonna let textField endEditing).
    //in this method I've just referred to a textField (instead of using the IBOutlet), because the textField class is the one responsible for calling these methods, and when it calls textFieldShouldEndEditing, it will pass a reference to the textField that triggered this method. We can have multiple textFields all triggering the same method.
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        if textField.text != "" {
            return true
        } else {
            textField.placeholder = "Type something"
            return false
        }
    }
    
    //textFieldDidEndEditing will be triggered when the user tap on searchButton or "Go" button to clear the textField.
    //used "if let" because searchTextField.text property is an optional and I wanted to pass to WeatherManager a String. So, it will optionally unwrap this property
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let city = searchTextField.text {
            //to get the weather for the cityName that the user has entered
            weatherManager.fetchWeather(cityName: city)
        }
        //empty String to clear textField
        searchTextField.text = ""
    }
}

//MARK: - WeatherManagerDelegate

extension WeatherViewController: WeatherManagerDelegate {
    
    func didUpdateWeather(_ weatherManager: WeatherManager, weather: WeatherModel) {
        //to update UI from within a completion handler (closure), dispatch the call to update UI to the main thread (update UI in the background)
        DispatchQueue.main.async {
            self.temperatureLabel.text = weather.temperatureString
            self.conditionImageView.image = UIImage(systemName: weather.conditionName)
            self.cityLabel.text = weather.cityName
        }
    }
    func didFailWithError(error: Error) {
        print(error)
    }
}

//MARK: - CLLocationManagerDelegate

extension WeatherViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationManager.stopUpdatingLocation()
            let lat = location.coordinate.latitude
            let lon = location.coordinate.longitude
            weatherManager.fetchWeather(latitude: lat, longitude: lon)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
