//
//  WeatherLocationFinder.swift
//  WeatherApp
//
//  Created by siva kongara on 1/7/16.
//  Copyright © 2016 siva kongara. All rights reserved.
//

import Foundation

class WeatherFromAPI: NSObject {

    func getWeekForecast (lattitude: String,longitude: String) -> [String] {
        let data = NSData(contentsOfURL: NSURL(string: apiURL + lattitude + "," + longitude)!)
        let json = parseJSON(data!)
        return apparentHighTempForWeek(json!)
    }
    
    private func parseJSON(inputData: NSData) -> NSDictionary? {
        var JsonDictionary: NSDictionary?
        do {
            JsonDictionary = try NSJSONSerialization.JSONObjectWithData(inputData, options: NSJSONReadingOptions.MutableContainers) as? NSDictionary
        } catch let error as NSError {
            print("JSON Parsinging error: \(error.localizedDescription)")
        }
        return JsonDictionary
    }
    
    private func apparentHighTempForWeek(json: NSDictionary) -> [String] {
        var apparentHighTempForWeekArray = [String]()
        if let weekData = json.objectForKey("daily") as? NSDictionary, weekDataArray = weekData.objectForKey("data") as? NSArray {
            for i in 0..<weekDataArray.count {
                let dayWeatherForecastDetails = weekDataArray[i] as? NSDictionary
                apparentHighTempForWeekArray.append("\((dayWeatherForecastDetails!["temperatureMax"])!)")
            }
        }
        return apparentHighTempForWeekArray
    }
    
}
