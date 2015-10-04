//
//  MapViewController.swift
//  WeTrain
//
//  Created by Bobby Ren on 8/1/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

    var requestedTrainingType: Int?
    var requestedTrainingLength: Int?
    
    @IBOutlet var mapView: GMSMapView!
    @IBOutlet var iconLocation: UIImageView!
    let locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    
    @IBOutlet var buttonRequest: UIButton!
    
    // address view
    @IBOutlet var viewAddress: UIView!
    @IBOutlet var inputStreet: UITextField!
    @IBOutlet var inputCity: UITextField!
    
    // request status
    var requestMarker: GMSMarker?
    
    var currentRequest: PFObject?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.buttonRequest.enabled = false
        
        locationManager.delegate = self
        
        if (locationManager.respondsToSelector("requestWhenInUseAuthorization")) {
            locationManager.requestWhenInUseAuthorization()
        }
        else {
            locationManager.startUpdatingLocation()
        }

        self.mapView.myLocationEnabled = true
        self.iconLocation.layer.zPosition = 1
        self.iconLocation.image = UIImage(named: "iconLocation")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.iconLocation.tintColor = UIColor(red: 215.0/255.0, green: 84.0/255.0, blue: 82.0/255.0, alpha: 1)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Close", style: UIBarButtonItemStyle.Done, target: self, action: "close")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        else if status == .Denied {
            print("Authorization is not available")
        }
        else {
            print("status unknown")
        }
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first as CLLocation? {
            locationManager.stopUpdatingLocation()
            
            self.currentLocation = location
            self.updateMapToCurrentLocation()
            self.enableRequest()
        }
    }

    func updateMapToCurrentLocation() {
        var zoom = self.mapView.camera.zoom
        if zoom < 12 {
            zoom = 17
        }
        self.mapView.camera = GMSCameraPosition(target: self.currentLocation!.coordinate, zoom: zoom, bearing: 0, viewingAngle: 0)
    }
    
    func enableRequest() {
        self.buttonRequest.enabled = true
        self.buttonRequest.layer.zPosition = 1
    }
    // MARK: - GMSMapView  delegate
    func didTapMyLocationButtonForMapView(mapView: GMSMapView!) -> Bool {
        self.view.endEditing(true)

        if self.currentLocation != nil {
            self.updateMapToCurrentLocation()
        }
        locationManager.startUpdatingLocation()
        return false
    }
    
    func mapView(mapView: GMSMapView!, idleAtCameraPosition position: GMSCameraPosition!) {
        self.currentLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        self.enableRequest()
    }
    
    // MARK: Location search
    @IBAction func didClickSearch(button: UIButton) {
        let address: String = "\(self.inputStreet.text) \(self.inputCity.text)"
        print("address: \(address)")
        
        self.view.endEditing(true)
        
        let coder = CLGeocoder()
        coder.geocodeAddressString(address, completionHandler: { (results, error) -> Void in
            if error != nil {
                print("error: \(error!.userInfo)")
                self.simpleAlert("Could not find that location", message: "Please check your address and try again")
            }
            else {
                print("result: \(results)")
                if let placemarks: [CLPlacemark]? = results as [CLPlacemark]? {
                    if let placemark: CLPlacemark = placemarks!.first as CLPlacemark! {
                        self.currentLocation = CLLocation(latitude: placemark.location!.coordinate.latitude, longitude: placemark.location!.coordinate.longitude)
                        self.updateMapToCurrentLocation()
                        self.enableRequest()
                    }
                }
            }
        })
    }
    
    // MARK: - TextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    // MARK: - request
    @IBAction func didClickRequest(sender: UIButton) {
        let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
        let payment = client.objectForKey("stripeToken")
        if payment == nil {
            self.simpleAlert("Please enter payment", message: "You must enter a credit card before requesting a trainer. Go to the Account tab to update your payment.")
            return
        }
        
        if self.currentLocation != nil {
            let coder = GMSGeocoder()
            coder.reverseGeocodeCoordinate(self.currentLocation!.coordinate, completionHandler: { (response, error) -> Void in
                if let gmresponse:GMSReverseGeocodeResponse = response as GMSReverseGeocodeResponse! {
                    let results: [AnyObject] = gmresponse.results()
                    let addresses: [GMSAddress] = results as! [GMSAddress]
                    let address: GMSAddress = addresses.first!
                    
                    var addressString: String = ""
                    let lines: [String] = address.lines as! [String]
                    for line: String in lines {
                        addressString = "\(addressString)\n\(line)"
                    }
                    print("Address: \(addressString)")
                    
                    self.confirmRequestForAddress(addressString, coordinate: address.coordinate)
                }
                else {
                    self.simpleAlert("Invalid location", message: "We could not request a visit; your current location is invalid")
                }
            })
        }
        else {
            self.simpleAlert("Invalid location", message: "We could not request a visit; your current location was invalid")
        }
    }
    
    func confirmRequestForAddress(addressString: String, coordinate: CLLocationCoordinate2D) {
        let alert: UIAlertController = UIAlertController(title: "Request trainer?", message: "Do you want to schedule a workout session around \(addressString)?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Let's Go", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            print("requesting")
            self.initiateTrainingRequest(addressString, coordinate: coordinate)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
        
    func initiateTrainingRequest(addressString: String, coordinate: CLLocationCoordinate2D) {
        var dict: [String: AnyObject] = [String: AnyObject]()
        dict = ["time": NSDate(), "lat": Double(coordinate.latitude), "lon": Double(coordinate.longitude), "status":RequestState.Searching.rawValue, "address": addressString]
        
        let request: PFObject = PFObject(className: "TrainingRequest", dictionary: dict)
        let client: PFObject = PFUser.currentUser()!.objectForKey("client") as! PFObject
        let id = client.objectId
        print("client: \(client) \(id)")
        request.setObject(client, forKey: "client")
        if self.requestedTrainingType != nil {
            let title = TRAINING_TITLES[self.requestedTrainingType!]
            request.setObject(title, forKey: "type")
        }
        if self.requestedTrainingLength != nil {
            request.setObject(self.requestedTrainingLength!, forKey: "length")
        }
        print("request: \(request)")
        request.saveInBackgroundWithBlock { (success, error) -> Void in
            print("saved: \(success)")
            client.setObject(request, forKey: "currentRequest")
            client.saveInBackground()

            self.currentRequest = request
            self.performSegueWithIdentifier("GoToRequestState", sender: nil)
        }
    }
        
    // MARK: - Navigation
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "GoToRequestState" {
            let controller: RequestStatusViewController = segue.destinationViewController as! RequestStatusViewController
            controller.currentRequest = self.currentRequest
        }
        else if segue.identifier == "GoToViewTrainer" {
            let controller: TrainerProfileViewController = segue.destinationViewController as! TrainerProfileViewController
        }
    }
}
