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
    
    private var cafes = [Cafe]()
    
    // This declares a constant that you’ll use to determine how far to search for
    // cafés from the user’s current location, as well as how far the user has 
    // to move before the app automatically refreshes the cafés. The distance here is in meters.
    let searchDistance: CLLocationDistance = 1000
  
    override func viewDidLoad() {
        super.viewDidLoad()

        self.locationManager = CLLocationManager()
        self.locationManager.delegate = self

        self.mapView.delegate = self
        
        // Add a refresh button
        self.navigationItem.leftBarButtonItem  =
            UIBarButtonItem(barButtonSystemItem: .Refresh,
                target: self, action: "refresh:")
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

       // Construct the URL that you’re going to use to ask Facebook for the places around the current location that match the search term “café.”
        // Notice that the use of string interpolation makes it simple to build a complex string.
        // This code would be much more complicated to read if it used NSString’s stringWithFormat:.
        var urlString = "https://graph.facebook.com/v2.0/search/"
        urlString += "?access_token="
        urlString +=
            "\(FBSession.activeSession().accessTokenData.accessToken)"
        urlString += "&type=place"
        urlString += "&q=cafe"
        urlString += "&center=\(location.coordinate.latitude),"
        urlString += "\(location.coordinate.longitude)"
        urlString += "&distance=\(Int(searchDistance))"
        
        // Convert the string into an NSURL. Even though the parameter to NSURL’s initializer is an NSString,
        // it still works with a Swift String object.
        // This is because String and NSString are seamlessly bridged.
        // You can use one in place of the other and Swift will handle the conversion for you—rather handy when using Cocoa APIs!
        let url = NSURL(string: urlString)!
//        let url = NSURL(string: urlString)
        
        println("Requesting from FB with URL: \(url)")
        
        let request = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(
            request,
            queue: NSOperationQueue.mainQueue())
        {
            (response: NSURLResponse!, data: NSData!, error: NSError!)
              -> Void in
            
            //  If there was an error fetching the data, such as the internet connection is offline, then we show an alert and return.
            if error != nil {
                let alert = UIAlertController(
                    title: "Oops!",
                    message: "An error occured",
                    preferredStyle: .Alert)
                alert.addAction(UIAlertAction(
                    title: "OK",
                    style: .Default,
                    handler: nil))
                self.presentViewController(
                    alert, animated: true, completion: nil)
                return
            }
            // This section of code performs JSON deserialization on the data returned from the Facebook graph API.
            // Existing Objective-C developers will be familiar with the error parameter here, which is part of a common pattern in Objective-C Cocoa development.
            // Because methods can’t have multiple return values, you pass a pointer to an NSError object into the method and then if there’s an error, you assign the reference to that error.
            // This pattern is no longer necessary in Swift, but it remains because all the Cocoa APIs still use it.
            // Swift handles this pattern neatly by allowing you to pass in a reference to an optional NSError, which gets sets in the same way if there’s an error.
            var error: NSError?
            let jsonObject: AnyObject! =
                NSJSONSerialization.JSONObjectWithData(
                    data, options: NSJSONReadingOptions(0), error: &error)
            
            //  You’re expecting the value returned from the JSON deserialization to be a JSON object—that is, a dictionary of strings to other JSON values types such as numbers, strings, arrays, objects and so forth.
            //  You know this because, like most APIs, that’s what the Facebook graph API returns. 
            //  This if-statement attempts to cast the jsonObject variable into a dictionary of String to AnyObject.
            //  If it is successfully downcast and there’s no error, then you’ve successfully retrieved valid data from the API.
            if let jsonObject = jsonObject as? [String:AnyObject] {
                if error == nil {
                    println("Data returned from FB:\n\(jsonObject)")

                    
                    //  This line uses the JSONValue helper defined in the file JSON.swift
                    //  You don’t know what types are inside a JSON object without looking at it. 
                    //  You could extract each bit of information manually and check its type, but the Swift code for that would be rather nested, with many if-statements doing downcast checks. 
                    //  JSONValue helps out by parsing the entire JSON structure into an enumeration with a case for each type that JSON supports.
                    if let data = JSONValue.fromObject(jsonObject)?["data"]?.array
                    {
                        // Create a new array to hold the Cafe objects that you’ll parse out of the data array.
                        var cafes: [Cafe] = []
                        for cafeJSON in data {
                            if let cafeJSON = cafeJSON.object {
                                // Create Cafe and add to array
                                if let cafe = Cafe.fromJSON(cafeJSON){
                                    cafes.append(cafe)
                                }
                            }
                        }
                        
                        // Remove the existing cafés from the map and add the new ones.
                        self.mapView.removeAnnotations(self.cafes)
                        self.cafes = cafes
                        self.mapView.addAnnotations(cafes)
                    }
                }
            }
        }
    }
    
    func refresh(sender: UIBarButtonItem) {
        if let location = self.lastLocation {
            self.centerMapOnLocation(location)
            self.fetchCafesAroundLocation(location)
        } else {
            let alert =
                UIAlertController(title: "Error",
                message: "No location yet!",
                preferredStyle: .Alert)
            alert.addAction(UIAlertAction(title: "OK",
                style: .Default,
                handler: nil))
            self.presentViewController(alert,
                animated: true,
                completion: nil)
        }
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
    
    
    // This map view delegate method is called when the map view needs a view to display an annotation.
    func mapView(mapView: MKMapView!,
            viewForAnnotation annotation: MKAnnotation!)
                -> MKAnnotationView!
    {
        //  You only handle Cafe annotations in this view controller. Other annotations, such as the user location (blue dot), you want the map view itself to handle. You therefore use a conditional downcast to pick out the annotations that are Cafe objects.
        if let annotation = annotation as? Cafe {
            let identifier = "pin"
            var view: MKPinAnnotationView
            
            // Map views maintain a reuse queue (similar to UITableView) so that you don’t need to keep creating annotations as new annotations come into view.
            // Instead, you can attempt to dequeue an existing annotation.
            // If there’s one in the reuse queue, then you want to use that. 
            // You use another conditional downcast to ensure that the view is of type MKPinAnnotationView.
            if let dequeuedView =
                mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                    as? MKPinAnnotationView
            {
                // If there is a view dequeued, then you only need to set the annotation on the
                //  view.
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                //  If no view could be dequeued, you create a new MKPinAnnotationView and set it up to show a button as the callout accessory.
                view = MKPinAnnotationView(annotation: annotation,
                                            reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView =
                    UIButton.buttonWithType(.DetailDisclosure) as UIView
            }
            // Finally, you return the annotation view.
            return view
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!,
        annotationView view: MKAnnotationView!,
        calloutAccessoryControlTapped control: UIControl!)
    {
        //  Instantiate a new CafeViewController by asking the storyboard to create one from the Storyboard ID you already set.
        // This could fail and return nil, so you employ the usual conditional optional unwrapping.
        if let viewController =
            self.storyboard!.instantiateViewControllerWithIdentifier(
                "CafeView") as? CafeViewController
        {
            
            // Check the annotation from the tapped view to see if it’s a Cafe object.
            // You know it is, but the compiler doesn’t because the type of the annotation property is MKAnnotation.
            if let cafe = view.annotation as? Cafe {
                
                // Set up the view controller and present it.
                viewController.cafe = cafe
                
                // Notice that you’ve declared the ViewController instance as the delegate of the CafeViewController.
                // You haven’t defined this delegate yet, 
                // but you’re going to use it to tell the ViewController when the user has finished with the CafeViewController—
                // that is, when the user has tapped the Back button.
                viewController.delegate = self
                
                self.presentViewController(viewController,
                    animated: true,
                    completion: nil
                )
            }
        }
    }
}

extension ViewController: CafeViewControllerDelegate {
    func cafeViewControllerDidFinish(viewController: CafeViewController)
    {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}




