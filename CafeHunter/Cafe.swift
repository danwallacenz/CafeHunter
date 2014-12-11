//
//  Cafe.swift
//  CafeHunter
//
//  Created by Daniel Wallace on 10/12/14.
//  Copyright (c) 2014 Razeware. All rights reserved.
//

import Foundation
import MapKit


// Something that could have been a Swift struct has to be a class. 
// You’ll find this is a common occurrence when interacting with Cocoa in Swift.
class  Cafe: NSObject {
    let fbid: String
    let name: String
    let location: CLLocationCoordinate2D
    let street: String
    let city: String
    let zip: String
    
    // This defines a computed property of type NSURL.
    var pictureURL: NSURL {
        return NSURL(string:
            "http://graph.facebook.com/place/picture?id=\(self.fbid)" +
            "&type=large")!
    }
    
    init(fbid: String, name: String,
        location: CLLocationCoordinate2D,
        street: String, city: String, zip: String)
    {
        self.fbid = fbid
        self.name = name
        self.location = location
        self.street = street
        self.city = city
        self.zip = zip
        
        super.init() // IMPORTANT
    }
    
    // This method’s job is to take the data found in the JSON for a single café and return a Cafe object if it parses correctly, or nil if it doesn’t.
    class func fromJSON(json: [String:JSONValue]) -> Cafe? {
        
        //  Pull the required parameters fbid, name, latitude and longitude out of the JSON. 
        // Notice the use of optional chaining to ensure very simple code. 
        // If the JSON doesn’t contain a value for the “id” key, then fbid will be nil. 
        // fbid will also be nil if the value it contains isn’t a string.
        let fbid = json["id"]?.string
        let name = json["name"]?.string
        let latitude = json["location"]?["latitude"]?.double
        let longitude = json["location"]?["longitude"]?.double
        
        
        // If the Facebook ID, name, latitude and longitude were successfully parsed, then you can create a Cafe.
        if fbid != nil && name != nil
            && latitude != nil && longitude != nil {
             
            // Here you handle the optional parameters. It’s OK if there’s no street, city, zip — you simply use an empty string.
            var street: String
            if let maybeStreet = json["location"]?["street"]?.string {
                street = maybeStreet
            } else {
                street = ""
            }
                
            var city: String
            if let maybeCity = json["location"]?["city"]?.string {
                city = maybeCity
            } else {
                city = ""
            }
                
            var zip: String
            if let maybeZip = json["location"]?["zip"]?.string {
                zip = maybeZip
            } else {
                zip = ""
            }
                
            let location =
                CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            // Create the Cafe from the data and return it.
            return Cafe(fbid: fbid!, name: name!, location: location,
                street: street, city: city, zip: zip)
        }
        // If you couldn’t create the Cafe because one of the required parameters was missing, then you return nil to signify an error.
        return nil
    }
    
    
}

extension Cafe: MKAnnotation {
    var title: String! {
        return name
    }
    var coordinate: CLLocationCoordinate2D {
        return location
    }
}
