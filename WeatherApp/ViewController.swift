//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mike on 2016-02-15.
//  Copyright © 2016 Mike. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet weak var cityNameTextField: UITextView!
    @IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var enterCity: UITextField!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var skyConditionsLabel: UILabel!
    
    var locationManager: CLLocationManager = CLLocationManager()
    var currentLocation: CLLocation!
    var loadCurrentWeatherOnce = true

    override func viewDidLoad() {
        super.viewDidLoad()
        // If there is an internet connection
        if Reachability.isConnectedToNetwork() == true {
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.delegate = self
            locationManager.requestAlwaysAuthorization()
            locationManager.startUpdatingLocation()
            currentLocation = nil
            
            // Hides keyboard
            self.enterCity.delegate = self;
            // If no internet connection, display alert
        } else {
            let alert = UIAlertView( title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK" )
            alert.show()
        }

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    // On button click, load weather data user entered in text field
    @IBAction func getWeather(sender: AnyObject) {
        // If there is an internet connection
        if Reachability.isConnectedToNetwork() == true {
            // getWeatherData function takes in stringBuilder function, which takes a string that the user inputs
            getWeatherData( stringBuilderFromText( self.enterCity.text! ) )
        } else {
            let alert = UIAlertView( title: "No Internet Connection", message: "Make sure your device is connected to the internet.", delegate: nil, cancelButtonTitle: "OK" )
            alert.show()
        }
    }
    
    func locationManager(manager: CLLocationManager,
        didUpdateLocations locations: [CLLocation])
    {
        if (loadCurrentWeatherOnce) {
            loadCurrentWeatherOnce = false
            let latestLocation: CLLocation = locationManager.location!
        
            getWeatherData( stringBuilderFromGPS( latestLocation.coordinate.latitude, lon: latestLocation.coordinate.longitude ) )
        }
    }

    // Builds the search string for openweathermap api
    // Takes a city name (string)
    func stringBuilderFromText(city: String) ->String {
        // Trim leading and trailing whitespace from the string
        let trimmedString = city.stringByTrimmingCharactersInSet( NSCharacterSet.whitespaceAndNewlineCharacterSet() )
        // Trim white space from middle of strings, example "Las Vegas"
        let noWhiteSpaceInString = trimmedString.stringByReplacingOccurrencesOfString(" ", withString: "")
        // Finished search string for openweathermap api
        let searchString = "http://api.openweathermap.org/data/2.5/weather?q=" + noWhiteSpaceInString + "&APPID=a14927833ec1779e7ef2634dd07ae47e"

        return searchString
    }
    
    // Builds the search string for openweathermap api
    // Takes a pair of gps coordinates, lat and lon (double)
    func stringBuilderFromGPS(lat: Double, lon: Double) ->String {
        // Search string with gps coordinates for openweathermap api
        let searchString = "http://api.openweathermap.org/data/2.5/weather?lat=" + String(lat) + "&lon=" + String(lon) + "&APPID=a14927833ec1779e7ef2634dd07ae47e"
        
        return searchString
    }
    
    func getWeatherData(urlString: String) {
        let url = NSURL( string: urlString )
        
        let task = NSURLSession.sharedSession().dataTaskWithURL( url! ) { ( data, responce, error ) in
            dispatch_async( dispatch_get_main_queue(), {
                self.setLabels( data! )
            })
        }
        task.resume()
        
    }
    
    // Used to hide keyboard once user hits enter
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func setLabels(weatherData: NSData) {

        do {
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: []) as! NSDictionary
            if let name = json["name"] as? String {
                cityNameLabel.text = name
            }

            if let main = json["main"] as? NSDictionary {
                if let temp = main["temp"] as? Double {
                    // To convert Kelvin to C, temp (K) - 273.15 = C
                    cityTempLabel.text = String( format: "%.1f", temp - 273.15 )
                }
                
                if let hum = main["humidity"] as? Double {
                    humidity.text = String(hum)
                }
            }
            
            if let weather = json["weather"] {
                if var skyConditions = weather[0]["description"] as? String {
                    // Strip off the extra text returned by the api
                    skyConditions = skyConditions.stringByReplacingOccurrencesOfString("\"", withString: "", options: NSStringCompareOptions.LiteralSearch, range: nil)
                    
                    skyConditionsLabel.text = skyConditions
                }
            }
            
        } catch {
            // error handling
        }
  }

}

