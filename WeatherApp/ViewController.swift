//
//  ViewController.swift
//  WeatherApp
//
//  Created by Mike on 2016-02-15.
//  Copyright © 2016 Mike. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var cityNameTextField: UITextView!
    @IBOutlet weak var cityTempLabel: UILabel!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var enterCity: UITextField!
    
    // On button click, load weather data user entered in text field
    @IBAction func getWeather(sender: AnyObject) {
        // getWeatherData function takes in stringBuilder function, which takes a string that the user inputs
        getWeatherData( stringBuilder( self.enterCity.text! ) )
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        //getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=Vancouver&APPID=a14927833ec1779e7ef2634dd07ae47e")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // Builds the search string for openweathermap api
    func stringBuilder(city: String) ->String {
        let searchString = "http://api.openweathermap.org/data/2.5/weather?q=" + city + "&APPID=a14927833ec1779e7ef2634dd07ae47e"
        
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
            }
        } catch {
            // error handling
        }
  }

}

