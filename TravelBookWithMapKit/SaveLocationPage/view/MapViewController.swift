//
//  ViewController.swift
//  TravelBookWithMapKit
//
//  Created by Uraz Alkış on 9.05.2023.
//

import UIKit
import MapKit
class MapViewController : UIViewController,MapViewModelOutput,MKMapViewDelegate,CLLocationManagerDelegate {
    private let viewModel : MapViewModel
    private let mapView = MKMapView()
    private let placeTextField = UITextField()
    private let explanationTextField = UITextField()
    private let saveButton : UIButton = {
        let button = UIButton()
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemGreen
        button.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 10
        return button
    }()
    init(viewModel:MapViewModel){
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        mapView.delegate = self
        setupLocationManager()
        addSubview()
       setupTextFieldConstraits()
        setupSaveButtonConstraits()
        setupGestureRecognizer()
        setInitialWidgetState()
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = CGRect(x: 0, y: view.frame.height/3.5, width:view.frame.width, height: view.frame.height/1.8)

    }
    func setInitialWidgetState(){
        if viewModel.selectedLocation != nil {
            saveButton.isHidden = true
            placeTextField.isEnabled = false
            explanationTextField.isEnabled = false
            placeTextField.text = viewModel.selectedLocation!.title
            explanationTextField.text = viewModel.selectedLocation!.subtitle
            
            let annotation = MKPointAnnotation()
            let latitude = viewModel.selectedLocation!.latitude
            let longitude = viewModel.selectedLocation!.longitude
            let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
            annotation.coordinate = coordinate
            self.mapView.addAnnotation(annotation)
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)//map zoom rate
            let region = MKCoordinateRegion(center: coordinate, span: span)
            mapView.setRegion(region, animated: true)
           // mapView.isPitchEnabled = false
            mapView.setRegion(region, animated: true)
        }
        else{
            saveButton.isHidden = false
            placeTextField.isEnabled = true
            explanationTextField.isEnabled = true
        }
    }
    @objc func chooseLocation(gestureRecognizer:UILongPressGestureRecognizer) {
        if gestureRecognizer.state == .began{
            let touchedPoint = gestureRecognizer.location(in: mapView)  //get location of press
            let touchedCoordinates = mapView.convert(touchedPoint, toCoordinateFrom: mapView)
            let annotation = MKPointAnnotation() // create pin on map
            annotation.coordinate = touchedCoordinates
            annotation.title=placeTextField.text
            annotation.subtitle = explanationTextField.text
            self.mapView.addAnnotation(annotation)
            viewModel.locationManager.stopUpdatingLocation()
            viewModel.pinnedLocationLatitude = touchedCoordinates.latitude
            viewModel.pinnedLocationLongitude = touchedCoordinates.longitude
            
        }
    }
   

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //locations list giving us a locationList.location[0] gives user's last location .
        if viewModel.selectedLocation == nil {
            let location = CLLocationCoordinate2D(latitude: locations[0].coordinate.latitude, longitude: locations[0].coordinate.longitude)//take current user location
            let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)//map zoom rate
            let region = MKCoordinateRegion(center: location, span: span)
            mapView.setRegion(region, animated: true)
        }
        
    }
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        //customize annotation
        if annotation is MKUserLocation {
            return nil    //remove pin from map when navigation
        }
        let reuseId = "MyAnnotation"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView  //check has any pin in view
        
        if pinView == nil {
            pinView  = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.canShowCallout = true
            pinView?.tintColor = .black //annotation color you can change if you want
            
            let button = UIButton(type: UIButton.ButtonType.detailDisclosure)
            pinView?.rightCalloutAccessoryView = button  //put button right side
            
        }
        else{
            pinView?.annotation = annotation
        }
        
        return pinView
    }
 
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // when click annotation accessory button this func called. we create navigation
        print("title: \(String(describing: viewModel.selectedLocation?.title))");
        if viewModel.selectedLocation != nil {
            let requestLocation = CLLocation(latitude: viewModel.selectedLocation!.latitude, longitude: viewModel.selectedLocation!.longitude)
            CLGeocoder().reverseGeocodeLocation(requestLocation) { placemarks, error in
                if let placemark = placemarks{
                    if !placemark.isEmpty {
                        let newPlacemark = MKPlacemark(placemark: placemark[0])
                        let item = MKMapItem(placemark: newPlacemark)
                        item.name = self.viewModel.selectedLocation?.title
                        
                        let launchOptions = [MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving]
                        item.openInMaps(launchOptions: launchOptions)
                    }
                }
            }//this class connects coordinates and places
        }
    }
    @objc func saveButtonTapped() {
        if placeTextField.text!.isEmpty || explanationTextField.text!.isEmpty {
            presentErrorAlert(title: "Hata", message:"Text alanlarını boş bırakmayın!")
        }
        else if viewModel.pinnedLocationLatitude == nil || viewModel.pinnedLocationLongitude==nil{
            presentErrorAlert(title: "Hata", message: "Lütfen haritadan bir konum seçiniz")
        }
        else{
            let savedLocation = SavedLocation(id: UUID(), title: placeTextField.text!, subtitle: explanationTextField.text!, latitude: viewModel.pinnedLocationLatitude!, longitude: viewModel.pinnedLocationLongitude!)
            viewModel.saveLocation(savedLocation: savedLocation)
            NotificationCenter.default.post(name: NSNotification.Name("newPlace"), object:nil)
            presentSuccessAlert(title: "Kayıt başarılı!", message: "\(placeTextField.text!) kaydı başarıyla gerçekleşti!")
            clear()
        }
       
    }
    func clear(){
        placeTextField.text = ""
        explanationTextField.text = ""
        viewModel.pinnedLocationLatitude = nil
        viewModel.pinnedLocationLongitude=nil
    }
    
    func addSubview(){
    
        view.addSubview(placeTextField)
        view.addSubview(explanationTextField)
        view.addSubview(mapView)
        view.addSubview(saveButton)
        
    }
   
    func presentSuccessAlert(title:String,message:String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
                present(alert, animated: true, completion: nil)
    }
    func presentErrorAlert(title:String,message:String){
        let alert = UIAlertController(title:title, message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default, handler: nil))
        alert.view.subviews.first?.backgroundColor = .red
                present(alert, animated: true, completion: nil)
    }
    
   
}

extension MapViewController {
    func setupGestureRecognizer(){
        let gestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(chooseLocation(gestureRecognizer:)))
       gestureRecognizer.minimumPressDuration = 2
       mapView.addGestureRecognizer(gestureRecognizer)
    }
    func setupLocationManager(){
        viewModel.locationManager.delegate = self
        viewModel.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        viewModel.locationManager.requestWhenInUseAuthorization()
        viewModel.locationManager.startUpdatingLocation()
    }
    func setupSaveButtonConstraits(){
        saveButton.translatesAutoresizingMaskIntoConstraints = false
            saveButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 20).isActive = true
            saveButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 100).isActive = true
            saveButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -100).isActive = true
            saveButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
    
    
    }
    func setupTextFieldConstraits() {
        placeTextField.placeholder = "Başlık"
        explanationTextField.placeholder = "Açıklama"
        
        placeTextField.borderStyle = .roundedRect
        explanationTextField.borderStyle = .roundedRect
        
        view.addSubview(placeTextField)
        view.addSubview(explanationTextField)
        
        // Place TextField Constraints
        placeTextField.translatesAutoresizingMaskIntoConstraints = false
        placeTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        placeTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        placeTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        placeTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        // Explanation TextField Constraints
        explanationTextField.translatesAutoresizingMaskIntoConstraints = false
        explanationTextField.topAnchor.constraint(equalTo: placeTextField.bottomAnchor, constant: 20).isActive = true
        explanationTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        explanationTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        explanationTextField.heightAnchor.constraint(equalToConstant: 40).isActive = true
    }
}

