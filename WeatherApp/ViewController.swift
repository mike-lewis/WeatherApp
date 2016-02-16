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
    
    @IBAction func getDataButton(sender: AnyObject) {
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        getWeatherData("http://api.openweathermap.org/data/2.5/weather?q=Vancouver&APPID=a14927833ec1779e7ef2634dd07ae47e")
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getWeatherData(urlString: String) {
        let url = NSURL(string: urlString)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url!) { (data, responce, error) in
            dispatch_async(dispatch_get_main_queue(), {
                self.setLabels(data!)
            })
        }
        print("before resume")
        task.resume()
        
    }
    
    func setLabels(weatherData: NSData) {

        do {
            let json = try NSJSONSerialization.JSONObjectWithData(weatherData, options: []) as! NSDictionary
            if let name = json["name"] as? String {
                cityNameLabel.text = name
                print(name)
            }

            if let main = json["main"] as? NSDictionary {
                if let temp = main["temp"] as? Double {
                    print(temp)
                    cityTempLabel.text = String(format: "%.1f", temp)

                }
            }
            print("almost end")
        } catch {
            //write error handling code here
            print("catch block")
        }
        print("end")
  }

}

