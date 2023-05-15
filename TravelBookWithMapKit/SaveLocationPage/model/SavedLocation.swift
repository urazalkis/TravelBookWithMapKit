//
//  SavedLocation.swift
//  TravelBookWithMapKit
//
//  Created by Uraz Alkış on 10.05.2023.
//

import Foundation


class SavedLocation : NSObject{
    let id : UUID
    let title : String
    let subtitle : String
    let latitude : Double
    let longitude : Double
    
    init(id: UUID, title: String, subtitle: String, latitude: Double, longitude: Double) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.latitude = latitude
        self.longitude = longitude
    }
}
