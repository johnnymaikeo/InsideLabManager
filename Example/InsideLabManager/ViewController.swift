//
//  ViewController.swift
//  InsideLabManager
//
//  Created by InsideLab on 07/05/2017.
//  Copyright (c) 2017 InsideLab. All rights reserved.
//

import UIKit
import InsideLabManager

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        
        let insidelab = InsideLab.manager
        insidelab.run(appUUID: "")
        
        var iBeaconsList:[iBeacon] = []
        iBeaconsList.append(iBeacon(minor: 123, major: 456))
        insidelab.monitor(iBeacons: iBeaconsList)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.iBeaconFound(_:)), name: insidelab.iBeaconFoundNotification, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func iBeaconFound(_ notification: NSNotification) {
        
        if let beacon = notification.userInfo?["iBeacon"] as? iBeacon {
            print(beacon.major)
        }
        
    }

}

