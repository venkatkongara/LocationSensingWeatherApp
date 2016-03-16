//
//  ViewController.swift
//  WeatherApp
//
//  Created by siva kongara on 1/7/16.
//  Copyright © 2016 Venkat kongara. All rights reserved.
//

// Note some Cities might not be supported by the Web API. SO it might show some city in the near longititude

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
    var city = ""
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .Gray)
    var lastLocationLattitude: Double?
    var lastLocationLongitude: Double?

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.orangeColor()
        tableView.registerNib(UINib(nibName: "WeatherTableViewCellView", bundle: nil), forCellReuseIdentifier: cellIdentifier)
        locationManger.delegate = self
        locationManger.desiredAccuracy = kCLLocationAccuracyThreeKilometers
        locationManger.requestAlwaysAuthorization()
        locationManger.startUpdatingLocation()
        tableView.alpha = 0
        activityIndicator.startAnimating()
        activityIndicator.frame = view.bounds
        view.addSubview(activityIndicator)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func fireLocalNotificationNow() {
        let notification = UILocalNotification()
        notification.alertTitle = "Location chaged"
        notification.hasAction = true
        notification.alertBody = "Updated the weekly weather forecast"
        notification.fireDate = NSDate()
        UIApplication.sharedApplication().scheduleLocalNotification(notification)
    }

}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        lattitude = "\(location!.coordinate.latitude)"
        longitude = "\(location!.coordinate.longitude)"
        
        if (lastLocationLattitude != location?.coordinate.latitude) && (lastLocationLongitude != location?.coordinate.longitude) {
            lastLocationLattitude = location?.coordinate.latitude
            lastLocationLongitude = location?.coordinate.longitude
            fireLocalNotificationNow()
        }
        
        // Does the background fetching and works even when app is in background
        dispatch_async(dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0)) {[weak self] () -> Void in
            self?.forecastData = WeatherFromAPI().getWeekForecast((self?.lattitude)!, longitude: (self?.longitude)!).0
            self?.city = WeatherFromAPI().getWeekForecast((self?.lattitude)!, longitude: (self?.longitude)!).1
            
            // updates UI on the main queue when back ground task is completed
            dispatch_async(dispatch_get_main_queue(), {[weak self] () -> Void in
                self?.tableView.reloadData()
                self?.tableView.alpha = 1
                self?.activityIndicator.stopAnimating()
            })
        }
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
            let dateString = "\(nextDate!)"
            let range = dateString.startIndex..<dateString.startIndex.advancedBy(11)
            tableViewCell?.city.text = city + "    " + dateString[range]
            tableViewCell?.temperatureHigh.text = "\(round(Float(forecastData[indexPath.row])!))"
        }
        return tableViewCell!
    }

}

extension ViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UIScreen.mainScreen().bounds.height/7
    }

}
