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
}

extension Cafe: MKAnnotation {
    var title: String! {
        return name
    }
    var coordinate: CLLocationCoordinate2D {
        return location
    }
}
