//
//  ViewController.swift
//  BackgroundLocator
//
//  Created by Y Jayaraman on 6/19/18.
//  Copyright © 2018 Y Jayaraman. All rights reserved.
//

import UIKit
import SwiftLocation
import Sentry

class ViewController: UIViewController {

    @IBOutlet weak var latLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        Locator.requestAuthorizationIfNeeded(.always)
        updateLocation()
        
    }

    func updateLocation() {
        Locator.subscribePosition(accuracy:.block, onUpdate: { (locs) -> (Void) in
            let latlongstring = String(locs.coordinate.latitude) + String(locs.coordinate.longitude)
            self.latLabel.text = latlongstring
            let lat_long_update = Event(level: .debug)
            lat_long_update.message = "Lat_Long_Update"
            lat_long_update.extra = ["lat+long+string": latlongstring]
            Client.shared?.send(event: lat_long_update) { (error) in
                // Optional callback after event has been send
            }

        }) { (fail, locs) -> (Void) in
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

