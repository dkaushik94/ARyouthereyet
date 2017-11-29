//
//  WeatherCall.swift
//  ARYouThereYet
//
//  Created by Amlaan Bhoi on 11/27/17.
//  Copyright © 2017 Debojit Kaushik . All rights reserved.
//

import Foundation
import CoreLocation

var temp: Float = 0.0

class WeatherCall {
    func getWeather(location: CLLocationCoordinate2D, handler: @escaping (NSDictionary?, NSError?) -> Void) {
        let url = URL(string: "http://api.openweathermap.org/data/2.5/weather?APPID=2ea48577574b26c2d63d4e3bfcb19d59&lat=\(location.latitude)&lon=\(location.longitude)")
        let task = URLSession.shared.dataTask(with: url!) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            } else {
                if let urlContent = data {
                    do {
                        let jsonResult = try JSONSerialization.jsonObject(with: urlContent, options: JSONSerialization.ReadingOptions.mutableContainers) as AnyObject
                        // print(jsonResult)
                        // print(jsonResult["name"])
                        // print(jsonResult.value(forKeyPath: "main.temp")!)
                        temp = jsonResult.value(forKeyPath: "main.temp") as! Float
                    } catch {
                        print("json error")
                    }
                }
            }
        }
        task.resume()
    }
}
