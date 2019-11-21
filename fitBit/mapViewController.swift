//
//  ViewController.swift
//  fitBit
//
//  Created by KAIZER WEB DESIGN on 05/11/2019.
//  Copyright © 2019 kaizer. All rights reserved.
//

import UIKit
import MapKit

class customPin: NSObject, MKAnnotation{
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    
    init(pinTitle:String, pinSubTitle:String, location:CLLocationCoordinate2D) {
        self.title = pinTitle
        self.subtitle = pinSubTitle
        self.coordinate = location
    }
}



class mapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var sourLat : Double = 0.0
    var sourLong : Double = 0.0
    var destLat : Double = 0.0
    var destLong : Double = 0.0
    var once = true
    var tracks : [Track] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
      /*  once = true
        if(once){
            print("Destination "+String(destLat)+" ----- "+String(destLong))
            print("Source "+String(sourLat)+" ----- "+String(sourLong))
            once=false
        }*/
        
        
        let sourceLocation = CLLocationCoordinate2D(latitude: sourLat, longitude: sourLong)
        let destinationLocation = CLLocationCoordinate2D(latitude: destLat, longitude: destLong)
        
        let region = MKCoordinateRegion(center: sourceLocation, latitudinalMeters: 800, longitudinalMeters: 800)
        
        let sourcePin = MKPointAnnotation()
        sourcePin.coordinate = sourceLocation
        sourcePin.title = "Start"
        mapView.addAnnotation(sourcePin)
        
        let destinationPin = MKPointAnnotation()
        destinationPin.coordinate = destinationLocation
        destinationPin.title = "Finish"
        mapView.addAnnotation(destinationPin)
        
        mapView.region = region
       
        
        var pointsToUse: [CLLocationCoordinate2D] = []
        
        var isTrackChanged = false
        
        var i : Int = 0
        for track in tracks{
            let x = CLLocationDegrees(track.latitude)
            let y = CLLocationDegrees(track.longitude)
            
            pointsToUse += [CLLocationCoordinate2DMake(x, y)]
            
            if i > 0{
                if pointsToUse[i-1].latitude != pointsToUse[i].latitude || pointsToUse[i-1].longitude != pointsToUse[i].longitude  {
                    isTrackChanged = true
                }
            }
            i += 1
        }
        
        let myPolyline = MKGeodesicPolyline(coordinates: &pointsToUse, count: tracks.count)
        
        
        mapView.addOverlay(myPolyline, level: .aboveRoads)
        
        self.mapView.setRegion(MKCoordinateRegion(myPolyline.boundingMapRect), animated: true)
        
        self.mapView.delegate = self
        
        /*let req = MKDirections.Request()
        req.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceLocation))
        req.destination = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation))
        req.transportType = .walking
        
        
        let directions = MKDirections(request: req)
        
        directions.calculate { (direct, err) in
            if err != nil{
                print((err?.localizedDescription)!)
                return
            }
           /* let polyline = direct?.routes.first?.polyline
            self.mapView.addOverlay(polyline!)
            self.mapView.setRegion(MKCoordinateRegion(polyline!.boundingMapRect), animated: true)*/
            
            let route = direct?.routes[0]
            self.mapView.addOverlay(route!.polyline, level: .aboveRoads)
            
            let rect = route?.polyline.boundingMapRect
            self.mapView.setRegion(MKCoordinateRegion(rect!), animated: true)
            
        }
        
        self.mapView.delegate = self*/
    }
    
    // MAPKIT DELEGATE
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.red
        renderer.lineWidth = 4.0
        return renderer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        mapView.removeAnnotations(mapView.annotations)
        mapView.removeOverlays(mapView.overlays)
        viewDidLoad()
    }


}

