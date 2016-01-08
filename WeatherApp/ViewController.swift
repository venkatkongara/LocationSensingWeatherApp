//
//  ViewController.swift
//  WeatherApp
//
//  Created by siva kongara on 1/7/16.
//  Copyright © 2016 siva kongara. All rights reserved.
//

import UIKit
import CoreLocation

let apiKey = "027e5d872610315888ddc20bb00af08e"
let apiURL = "https://api.forecast.io/forecast/" + apiKey + "/"

class ViewController: UIViewController {
    
    let cellIdentifier = "customWeatherCell"
    let todaysDate = NSDate()
    var tableViewCell: WeatherViewTableViewCell?
    var lattitude = ""
    var longitude = ""
    let locationManger = CLLocationManager()
    var forecastData = [String]()

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orangeColor()
        tableView.registerNib(UINib(nibName: "WeatherTableViewCellView", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManger.requestAlwaysAuthorization()
        locationManger.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        lattitude = "\(location!.coordinate.latitude)"
        longitude = "\(location!.coordinate.longitude)"
        forecastData = WeatherFromAPI().getWeekForecast(lattitude, longitude: longitude)
        tableView.reloadData()
    }
    
    func locationManager(manager: CLLocationManager, didFailWithError error: NSError) {
        let alertVC =  UIAlertController(title: "Error Finding Location", message: "\(error.localizedDescription)", preferredStyle: .Alert)
        alertVC.addAction(UIAlertAction(title: "Please enable location services", style: UIAlertActionStyle.Default, handler: nil))
        presentViewController(alertVC, animated: false, completion: nil)
    }
    
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            case .NotDetermined , .Restricted , .Denied :
                locationManger.requestAlwaysAuthorization()
                locationManger.startUpdatingLocation()
            break
            default : break
        }
    }

}

extension ViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as? WeatherViewTableViewCell
        if(tableViewCell == nil) {
            tableViewCell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as? WeatherViewTableViewCell
        }
        if forecastData.count > 0 {
            let dayComponent = NSDateComponents()
            dayComponent.day = indexPath.row - 1;
            let theCalendar = NSCalendar.currentCalendar()
            let nextDate = theCalendar.dateByAddingComponents(dayComponent, toDate: NSDate(), options: .MatchStrictly)
            tableViewCell?.city.text = "\(nextDate!)"
            tableViewCell?.temperatureHigh.text = forecastData[indexPath.row]
        }
        return tableViewCell!
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.height/7
    }

}
