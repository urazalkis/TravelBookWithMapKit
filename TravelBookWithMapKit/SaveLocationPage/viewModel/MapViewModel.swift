//
//  File.swift
//  TravelBookWithMapKit
//
//  Created by Uraz Alkış on 9.05.2023.
//

import Foundation
import CoreLocation
import CoreData
import UIKit

class MapViewModel{
    weak var output : MapViewModelOutput?
    var locationManager : CLLocationManager
    var pinnedLocationLatitude : Double?
    var pinnedLocationLongitude : Double?
    var selectedLocation : SavedLocation?
    init(output: MapViewModelOutput? = nil,locationManager : CLLocationManager,selectedLocation :SavedLocation?) {
        self.output = output
        self.locationManager = locationManager
        self.selectedLocation = selectedLocation
    }
    func saveLocation(savedLocation : SavedLocation){
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newPlace = NSEntityDescription.insertNewObject(forEntityName: "Places", into: context)
        
        newPlace.setValue(savedLocation.title, forKey: "title")
        newPlace.setValue(savedLocation.subtitle, forKey: "subtitle")
        newPlace.setValue(savedLocation.latitude, forKey: "latitude")
        newPlace.setValue(savedLocation.longitude, forKey: "longitude")
        newPlace.setValue(savedLocation.id, forKey: "id")
        do {
            try context.save()
            print("success")
        } catch{
            print("error")
        }
        
    }
    
    
}
