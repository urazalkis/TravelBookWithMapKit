//
//  SavedLocationsViewController.swift
//  TravelBookWithMapKit
//
//  Created by Uraz Alkış on 11.05.2023.
//

import UIKit
import CoreLocation
import CoreData

class SavedLocationsViewController: UIViewController,SavedLocationsOutput,UITableViewDataSource,UITableViewDelegate{
    private let viewModel : SavedLocationsViewModel
    private let tableView : UITableView = UITableView()
    
    init(viewModel:SavedLocationsViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        viewModel.setDelegate(output: self)
        tableView.frame = view.bounds
        view.addSubview(tableView)
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClick))

        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadTableData), name: NSNotification.Name("newPlace"), object: nil)

    }

    @objc func reloadTableData(){
        tableView.reloadData()
    }
    @objc func addButtonClick(){
        let mapVC = MapViewController(viewModel: MapViewModel(locationManager: CLLocationManager(),selectedLocation: nil))
        self.navigationController?.pushViewController(mapVC, animated: true)
        //present(mapVC, animated: true, completion: nil)
    
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.getSavedDatas().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell  = UITableViewCell()
        cell.textLabel?.text = viewModel.getSavedDatas()[indexPath.row].title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedRow = viewModel.getSavedDatas()[indexPath.row]
        let mapVC = MapViewController(viewModel: MapViewModel(locationManager: CLLocationManager(), selectedLocation: selectedRow))
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            viewModel.deleteData(id: viewModel.getSavedDatas()[indexPath.row].id)
        }
    }
        
}
