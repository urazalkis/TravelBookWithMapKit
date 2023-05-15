//
//  SavedLocationsViewModel.swift
//  TravelBookWithMapKit
//
//  Created by Uraz Alkış on 11.05.2023.
//

import Foundation
import CoreData
import UIKit
class SavedLocationsViewModel{
    var savedLocationsOutput : SavedLocationsOutput?
    
    func setDelegate(output: SavedLocationsOutput) {
        savedLocationsOutput = output
    }
    func getSavedDatas() -> [SavedLocation]{
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName:"Places")
      //  request.predicate = NSPredicate(format: "id = %@",id) if you want pull data for id,use this syntax
        request.returnsObjectsAsFaults = false
        
        do{
         let results = try context.fetch(request)
            
            if !results.isEmpty {
               let nsResults =  results as! [NSManagedObject]

                return convertToSavedLocation(nsResults)
                savedLocationsOutput?.reloadTableData()
            }
            else{
                return []
            }
        }
        catch {
            return []
        }
    }

    private  func convertToSavedLocation(_ managedObjects: [NSManagedObject]) -> [SavedLocation] {
        // convert coreData nsManagedObject to SavedLocation model
        var savedLocationList : [SavedLocation] = []
        for managedObject in managedObjects {
            
            guard let id = managedObject.value(forKey: "id") as? UUID,
                  let title = managedObject.value(forKey: "title") as? String,
                  let subtitle = managedObject.value(forKey: "subtitle") as? String,
                  let latitude = managedObject.value(forKey: "latitude") as? Double,
                  let longitude = managedObject.value(forKey: "longitude") as? Double
            else {
                return []
            }
            let savedLocation = SavedLocation(id: id, title: title, subtitle: subtitle, latitude: latitude, longitude: longitude)
            savedLocationList.append(savedLocation)
        }
            return savedLocationList
    }
    func deleteData(id : UUID)
    {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName:"Places")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id.uuidString)
        fetchRequest.returnsObjectsAsFaults = false
        do{
            let results = try context.fetch(fetchRequest)
            if !results.isEmpty {
                guard let entityToDelete = results.first as? NSManagedObject else { return }
        
                context.delete(entityToDelete)
                try context.save()
                savedLocationsOutput?.reloadTableData()
                /*for result in results as! [NSManagedObject] {
                    context.delete(result)
                       context.save()
                    break
                }*/
            }
        }
        catch{
            
        }
        
        
        
           
       
        
    }
    
}
