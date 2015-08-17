//
//  MapViewController.swift
//  DocPronto
//
//  Created by Bobby Ren on 8/1/15.
//  Copyright (c) 2015 Bobby Ren. All rights reserved.
//

import UIKit
import GoogleMaps
import Parse

enum RequestState: String {
    case NoRequest = "none"
    case Searching = "requested"
    case Matched = "matched"
    case Cancelled = "cancelled"
}

class MapViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {

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
    var requestState: RequestState = .NoRequest
    var requestMarker: GMSMarker?
    
    var currentRequest: PFObject?
    var timer: NSTimer?
    
    @IBOutlet var requestStatusView: UIView!
    var requestController: RequestStatusViewController?
    var showingRequestStatus: Bool = false
    
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
        
        self.toggleRequestState(.NoRequest)

        // load previous request if one exists
        self.updateRequestState()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func close() {
        self.toggleRequestState(RequestState.NoRequest)
        self.navigationController!.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
        else if status == .Denied {
            println("Authorization is not available")
        }
        else {
            println("status unknown")
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        if let location = locations.first as? CLLocation {
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
        if self.showingRequestStatus {
            self.requestStatusView.layer.zPosition = 1
            self.buttonRequest.layer.zPosition = 2
        }
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
        if self.showingRequestStatus == false {
            self.enableRequest()
        }
    }
    
    // MARK: Location search
    @IBAction func didClickSearch(button: UIButton) {
        var address: String = "\(self.inputStreet.text) \(self.inputCity.text)"
        println("address: \(address)")
        
        self.view.endEditing(true)
        
        let coder = CLGeocoder()
        coder.geocodeAddressString(address, completionHandler: { (results, error) -> Void in
            if error != nil {
                println("error: \(error.userInfo)")
                self.simpleAlert("Could not find that location", message: "Please check your address and try again")
            }
            else {
                println("result: \(results)")
                if let placemarks: [CLPlacemark] = results as? [CLPlacemark] {
                    if let placemark: CLPlacemark = placemarks.first as CLPlacemark! {
                        self.currentLocation = CLLocation(latitude: placemark.location.coordinate.latitude, longitude: placemark.location.coordinate.longitude)
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
        if self.requestState == RequestState.Searching {
            self.toggleRequestState(self.requestState)
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
                    println("Address: \(addressString)")
                    
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
        var alert: UIAlertController = UIAlertController(title: "Request doctor?", message: "Do you want to schedule a visit at \(addressString)?", preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Pronto!", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            println("requesting")
            self.toggleRequestState(RequestState.Searching)
            self.initiateVisitRequest(addressString, coordinate: coordinate)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func toggleRequestState(newState: RequestState) {
        self.requestState = newState

        switch self.requestState {
        case .NoRequest:
            self.buttonRequest.setTitle("Request a visit here", forState: UIControlState.Normal)
            if self.requestMarker != nil {
                self.requestMarker!.map = nil
                self.requestMarker = nil
                self.iconLocation.hidden = false
            }
            self.currentRequest = nil
            if self.timer != nil {
                self.timer!.invalidate()
                self.timer = nil
            }
            
            self.buttonRequest.enabled = true
            self.hideRequestView()
            return
        case .Cancelled:
            // request state is set to .NoRequest if cancelled from an app action. 
            // "cancelled" state is set on the web in order to trigger this state
            if self.currentRequest != nil {
                self.currentRequest!.setObject(RequestState.NoRequest.rawValue, forKey: "status")
                self.currentRequest!.saveInBackgroundWithBlock({ (success, error) -> Void in

                    let title = "Search was cancelled"
                    var message: String? = self.currentRequest!.objectForKey("cancelReason") as? String
                    if message == nil {
                        message = "You have cancelled the doctor's visit."
                    }
                    
                    self.requestController!.updateTitle(title, message: message!, top: nil, bottom: "OK", topHandler: nil, bottomHandler: { () -> Void in
                        self.hideRequestView()
                        self.toggleRequestState(RequestState.NoRequest)
                    })
                    self.showRequestView()
                })
            }
            else {
                self.toggleRequestState(RequestState.NoRequest)
            }
            return
        case .Searching:
            
            var title = "Searching for a doctor near you"
            var message = "Please be patient while we connect you with a doctor. If this is an emergency, dial 911!"
            if let addressString: String = self.currentRequest?.objectForKey("address") as? String {
                title = "Searching for a doctor near:"
                message = "\(addressString)\n\n\(message)"
            }
            self.requestController!.updateTitle(title, message: message, top: nil, bottom: "Cancel", topHandler: nil, bottomHandler: { () -> Void in
                self.toggleRequestState(RequestState.Cancelled)
            })

            self.buttonRequest.enabled = false
            self.showRequestView()
            
            if self.requestMarker == nil {
                var marker = GMSMarker()
                marker.position = self.currentLocation!.coordinate
                marker.title = "Doctor's Visit"
                marker.snippet = "I need a doc, pronto"
                marker.map = self.mapView
                marker.icon = UIImage(named: "iconLocation")!
                self.requestMarker = marker
                
                self.iconLocation.hidden = true
            }
            
            if self.timer == nil {
                self.timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: "updateRequestState", userInfo: nil, repeats: true)
            }
            
            break
        case .Matched:
            let title = "A doctor was matched!"
            let message = "Expect a call within the next hour from Dr. Klein."
            self.requestController!.updateTitle(title, message: message, top: "See doctor", bottom: "OK", topHandler: { () -> Void in
                self.viewDoctorInfo()
            }, bottomHandler: { () -> Void in
                self.hideRequestView()
            })
            self.showRequestView()

            break
        default:
            break
        }
    }
    
    func initiateVisitRequest(addressString: String, coordinate: CLLocationCoordinate2D) {
        var dict: [String: AnyObject] = [String: AnyObject]()
        dict = ["time": NSDate(), "lat": Double(coordinate.latitude), "lon": Double(coordinate.longitude), "status":RequestState.Searching.rawValue, "address": addressString]
        
        let request: PFObject = PFObject(className: "VisitRequest", dictionary: dict)
        request.setObject(PFUser.currentUser()!, forKey: "patient")
        request.saveInBackgroundWithBlock { (success, error) -> Void in
            println("saved: \(success)")
            self.currentRequest = request
            PFUser.currentUser()!.setObject(request, forKey: "currentRequest")
            PFUser.currentUser()!.saveInBackground()
        }
    }
    
    func updateRequestState() {
        if let request: PFObject = PFUser.currentUser()!.objectForKey("currentRequest") as? PFObject {
            request.fetchInBackgroundWithBlock({ (object, error) -> Void in
                self.currentRequest = object
                if self.currentRequest == nil {
                    // if request is still nil, then it got cancelled/deleted somehow.
                    self.toggleRequestState(.NoRequest)
                    return
                }

                if let previousState: String = self.currentRequest!.objectForKey("status") as? String{
                    let newState: RequestState = RequestState(rawValue: previousState)!
                    
                    if newState == RequestState.Searching {
                        let previousLat: Double? = self.currentRequest?.objectForKey("lat") as? Double
                        let previousLon: Double? = self.currentRequest?.objectForKey("lon") as? Double
                        
                        if previousLat != nil && previousLon != nil {
                            self.currentLocation = CLLocation(latitude: previousLat!, longitude: previousLon!)
                            self.updateMapToCurrentLocation()
                        }
                    }
                    else if newState == RequestState.Cancelled {
                        // cancelled
                    }
                    else if newState == RequestState.Matched {
                        // doctor
                        if let doctor: PFObject = request.objectForKey("doctor") as? PFObject {
                            doctor.fetchInBackgroundWithBlock({ (object, error) -> Void in
                                println("doctor: \(object)")
                            })
                        }
                    }
                    self.toggleRequestState(newState)
                }
            })
        }
    }
    
    func hideRequestView() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.requestStatusView.alpha = 0
        }) { (done) -> Void in
            self.showingRequestStatus = false
        }
    }
    
    func showRequestView() {
        UIView.animateWithDuration(0.25, animations: { () -> Void in
            self.requestStatusView.alpha = 1
            }) { (done) -> Void in
                self.showingRequestStatus = true
        }
    }
    
    func didGetDoctor() {
        // TODO: this would be a delegate function for a parse call
        if self.requestState == RequestState.Searching {
            self.toggleRequestState(RequestState.Matched)
            if self.currentLocation != nil {
            }
        }
    }

    // TODO
    func viewDoctorInfo() {
        println("display doctor info")
        self.performSegueWithIdentifier("GoToViewDoctor", sender: nil)
    }
    
    func simpleAlert(title: String?, message: String?) {
        var alert: UIAlertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "EmbedRequestStatusViewController" {
            self.requestController = segue.destinationViewController as! RequestStatusViewController
        }
    }

}
