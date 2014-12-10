/*
* Copyright (c) 2014 Razeware LLC
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
*/

import UIKit
import MapKit

class ViewController: UIViewController {
  
    @IBOutlet var mapView: MKMapView!
    // turn into = weak var mapView: MKMapView!
    
    @IBOutlet var loginView: FBLoginView!
    //turn into = weak var loginView: FBLoginView!
    
    private var locationManager: CLLocationManager!
    
    // You’ll use this to hold the user’s last known location.
    // It’s an optional because you might not have a last location—that is, 
    // you might not have found the location yet.
    private var lastLocation: CLLocation?
    
    // This declares a constant that you’ll use to determine how far to search for
    // cafés from the user’s current location, as well as how far the user has 
    // to move before the app automatically refreshes the cafés. The distance here is in meters.
    let searchDistance: CLLocationDistance = 3000
  
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self

        self.mapView.delegate = self
    }
  
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        self.checkLocationAuthorizationStatus()
    }

    private func checkLocationAuthorizationStatus() {
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            // Show the user’s location if the user has authorized the app to do so.
            self.mapView.showsUserLocation = true
        } else {
            self.locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    //  This takes the passed-in location and centers the map view on that location. 
    // You size the region of the map based on the search distance constant, 
    // so it will be big enough to show all the cafés once you’ve fetched them.
    private func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion =
            MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                searchDistance,
                                                searchDistance)
        self.mapView.setRegion(coordinateRegion, animated: true)
    }
    
    private func fetchCafesAroundLocation(location: CLLocation) {
        
        // Displays an error if the Facebook session isn’t open yet. 
        // An open session is one in which the user is logged in. 
        // The Facebook graph API requires a user access token, 
        // so your user needs to be logged in before the app can fetch the data it needs.
        if !FBSession.activeSession().isOpen {
            let alert =
                UIAlertController(title: "Error",
                    message: "Login first!",
                    preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK",
                                            style: .Default,
                                            handler: nil))
            self.presentViewController(alert,
                animated: true,
                completion: nil)
            return
        }
        
        // TODO
    }

}

extension ViewController: CLLocationManagerDelegate {
  
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        self.checkLocationAuthorizationStatus()
    }
  
}

extension ViewController: MKMapViewDelegate {
    
    func mapView(mapView: MKMapView!,
        didFailToLocateWithError error: NSError!)
    {
        println(error)
        let alert =
            UIAlertController(title: "Error",
                message: "Failed to obtain location!",
                preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK",
            style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    
    func mapView(mapView: MKMapView!,
        didUpdateUserLocation userLocation: MKUserLocation!)
    {
        // Retrieve the new location from the delegate method’s userLocation parameter.
        let newLocation = userLocation.location
        
        //  Calculate the distance from the last location. Note the use of the question mark when obtaining the lastLocation property value. 
        // lastLocation is an optional property, meaning its value may be nil. 
        // If it is, then this expression returns nil and stops processing. 
        // Only if there is a concrete value in lastLocation is distanceFromLocation called on it. 
        // For this reason, the local distance variable is also an optional.
        let distance = self.lastLocation?.distanceFromLocation(newLocation)
        
        // Update the map if there’s no previous distance or if the user has moved by a certain amount.
        // Since distance is an optional, you can do this check very easily in one if-statement. 
        // Without optionals, this code would need to be more complex, 
        // because you wouldn’t be able to tell the difference between no distance value and a distance value of 0.
        if distance == nil || distance! > searchDistance {
            self.lastLocation = newLocation
            self.centerMapOnLocation(newLocation)
            self.fetchCafesAroundLocation(newLocation)
        }
    }
}






