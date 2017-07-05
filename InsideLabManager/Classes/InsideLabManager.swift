//
//  InsideLabManager.swift
//  development
//
//  Created by InsideLab on 10/18/16.
//  Copyright © 2016 insidelab. All rights reserved.
//

import Foundation
import CoreLocation
import UIKit
import SystemConfiguration

struct defaultsKeys {
    static let currentRegionName = "RegionName"
    static let currentRegionUUID = "RegionUUID"
    static let iBeaconQueueParameters = "iBeaconQueueParameters"
}

public class iBeacon {
    
    public var datetime: NSDate
    public var minor: NSNumber
    public var major: NSNumber
    public var uuid: NSUUID
    public var region: String?
    public var proximity: CLProximity = CLProximity.unknown
    public var accuracy: CLLocationAccuracy?
    public var rssi: Int?
    
    public init() {
        
        self.datetime = NSDate()
        self.minor = 0.0
        self.major = 0.0
        self.uuid = NSUUID.init()
        
    }
    
    public init(minor: NSNumber, major: NSNumber) {
        
        self.datetime = NSDate()
        self.uuid = NSUUID.init()
        
        self.minor = minor
        self.major = major
        
    }
    
    public init(datetime: NSDate, minor: NSNumber, major: NSNumber, uuid: NSUUID) {
        
        self.datetime = datetime
        self.minor = minor
        self.major = major
        self.uuid = uuid
        
    }
    
}

public class InsideLab: NSObject, CLLocationManagerDelegate {
    
    public let iBeaconFoundNotification = Notification.Name("iBeaconFoundNotification")
    
    public static let manager: InsideLab = InsideLab()
    let locationManager: CLLocationManager = CLLocationManager()
    var lastBeaconRead: iBeacon = iBeacon()
    var appUUID: String = ""
    var iBeaconListToMonitor: [iBeacon] = []
    
    public override init() {
        super.init()
    }
    
    /**
     
     start iBeacons location manager
     - parameter appUUID: Application unique identifier
     - returns: void
     
     */
    
    public func run(appUUID: String) {
        
        self.appUUID = appUUID
        locationManager.delegate = self
        
        // request authorization to run on background
        locationManager.requestAlwaysAuthorization()
        locationManager.startMonitoringSignificantLocationChanges()
        
    }
    
    /**
     
     initiate list of iBeacons to be monitored
     - parameter iBeacons: List of iBeacons
     - return: void
     
     */
    
    public func monitor(iBeacons: [iBeacon]) {
        self.iBeaconListToMonitor = iBeacons
    }
    
    /**
     
     start monitoring region based on uuid received from server
     - return: void
     
     */
    
    private func startMonitoring() -> Void {
        
        var beaconRegion:CLBeaconRegion!
        beaconRegion = CLBeaconRegion(proximityUUID: self.lastBeaconRead.uuid as UUID, identifier: self.lastBeaconRead.region!)
        beaconRegion.notifyOnEntry = true
        beaconRegion.notifyOnExit = true
        beaconRegion.notifyEntryStateOnDisplay = true
        
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        
    }
    
    /**
     
     stop monitoring region, used to change UUID and region when a new location is defined
     - return: void
     
     */
    
    private func stopMonitoring() -> Void {
        
        if (self.lastBeaconRead.region != nil) {
            var beaconRegion:CLBeaconRegion!
            beaconRegion = CLBeaconRegion(proximityUUID: self.lastBeaconRead.uuid as UUID, identifier: self.lastBeaconRead.region!)
            locationManager.stopMonitoring(for: beaconRegion)
            locationManager.stopRangingBeacons(in: beaconRegion)
        }
        
    }
    
    /**
     
     get device unique identifier
     - returns: device identifier
     
     */
    
    private func getDeviceUniqueId () -> String {
        return UIDevice.current.identifierForVendor!.uuidString
    }
    
    /**
     
     update last ibeacon object with properties from ibeacon found on didRangeBeacons
     - parameter ibeacon: CLBeacon object received from didRangeBeacons
     - returns: void
     
     */
    
    private func updateLastBeaconRead(ibeacon: CLBeacon) {
        self.lastBeaconRead.accuracy = ibeacon.accuracy
        self.lastBeaconRead.proximity = ibeacon.proximity
        self.lastBeaconRead.rssi = ibeacon.rssi
        self.lastBeaconRead.datetime = NSDate()
    }
    
    /**
     
     create parameters string on rangin ibeacons
     - parameter app: application identifier
     - parameter device: device unique identifier
     - parameter ibeacon: iBeacon
     - returns: parameters string
     
     */
    
    private func createParametersString(app: String, device: String, ibeacon: iBeacon) -> String {
        var parameters: String
        parameters = "app=\(app)&device=\(device)&date=\(ibeacon.datetime)&uuid=\(ibeacon.uuid.uuidString)&major=\(ibeacon.major)&minor=\(ibeacon.minor)&proximity=\(ibeacon.proximity)"
        return parameters
    }
    
    /**
     
     create parameters string on getting region uuid
     - paramater app: application identifier
     - parameter device: device unique identifier
     - parameter latitude: current position latitude
     - parameter longitude: current position longitude
     
     */
    
    private func createParametersString(app: String, device: String, latitude: String, longitude: String) -> String {
        var parameters: String
        parameters = "app=\(app)&device=\(device)&latitude=\(latitude)&longitude=\(longitude)"
        return parameters
    }
    
    /**
     
     Save ibeacons setttins in parameter format to send to server when
     internet connection is available
     - returns: void
     
     */
    
    private func saveBeaconToSendWhenConnectionIsAvailable(parameters: String) -> Void {
        
        let defaults = UserDefaults.standard
        
        var iBeaconQueueParameters: [String] = []
        
        if (defaults.object(forKey: defaultsKeys.iBeaconQueueParameters) != nil)
        {
            iBeaconQueueParameters = defaults.stringArray(forKey: defaultsKeys.iBeaconQueueParameters)!
        }
        
        iBeaconQueueParameters.append(parameters)
        defaults.set(iBeaconQueueParameters, forKey: defaultsKeys.iBeaconQueueParameters)
        
    }
    
    /**
     
     post ibeacons stored on user defaults to server
     when internet access is available
     - returns: void
     
     */
    
    private func postBeaconToServerOnceInternetIsAvailable() -> Void {
        
        let defaults = UserDefaults.standard
        
        if (defaults.object(forKey: defaultsKeys.iBeaconQueueParameters) != nil)
        {
            var iBeaconQueueParameters: [String]!
            iBeaconQueueParameters = defaults.stringArray(forKey: defaultsKeys.iBeaconQueueParameters)! as [String]
            
            while iBeaconQueueParameters.count > 0
            {
                let element = iBeaconQueueParameters.first! as String
                postBeaconToAzure(parameters: element)
                iBeaconQueueParameters.remove(at: 0)
            }
        }
        
    }
    
    /**
     
     post update to service on azure
     - parameter ibeacon: iBeacon object
     - returns: void
     
     */
    
    private func postBeaconToAzure(parameters: String) -> Void {
        
        HttpRequest.post(url: "https://ibeacontrollerdevapi.azurewebsites.net/ibeacon/range", parameters: parameters) {
            response in
            print(response)
        }
        
    }
    
    /**
     
     check internet connection before posting to server
     - parameter ibeacon: iBeacon object
     - returns: void
     
     */
    
    private func checkConnectionAndPostBeaconStatusToServer(parameters: String) {
        
        if Reachability.isInternetAvailable() == true
        {
            postBeaconToAzure(parameters: parameters)
            postBeaconToServerOnceInternetIsAvailable()
        }
        else
        {
            saveBeaconToSendWhenConnectionIsAvailable(parameters: parameters)
        }
        
    }
    
    /**
     
     post user current location to server to get uuid before start ranging
     - parameter parameters: string with parameters to post
     returns: void
     
     */
    
    private func postUserLocationToServer(parameters: String) {
        
        if Reachability.isInternetAvailable() == true
        {
            HttpRequest.post(url: "https://ibeacontrollerdevapi.azurewebsites.net/ibeacon/region", parameters: parameters) {
                response in
                do {
                    let parse = try JSONSerialization.jsonObject(with: response.data(using: String.Encoding.utf8)!, options: JSONSerialization.ReadingOptions.allowFragments) as! [String:Any]
                    
                    let uuid = parse["UUID"] as! String
                    let identifier = parse["identifier"] as! String
                    
                    self.lastBeaconRead.uuid = NSUUID.init(uuidString: uuid)!
                    self.lastBeaconRead.region = identifier
                    
                    UserDefaults.standard.setValue(uuid, forKeyPath: defaultsKeys.currentRegionUUID)
                    UserDefaults.standard.setValue(identifier, forKeyPath: defaultsKeys.currentRegionName)
                    
                    self.startMonitoring()
                } catch let error as NSError {
                    print (error)
                }
            }
        }
        else
        {
            if (UserDefaults.standard.object(forKey: defaultsKeys.currentRegionUUID) != nil && UserDefaults.standard.object(forKey: defaultsKeys.currentRegionName) != nil)
            {
                
                self.lastBeaconRead.uuid = NSUUID.init(uuidString: UserDefaults.standard.value(forKey: defaultsKeys.currentRegionUUID) as! String)!
                self.lastBeaconRead.region = UserDefaults.standard.value(forKey: defaultsKeys.currentRegionName) as! String?
                
                self.startMonitoring()
                
            }
        }
    }
    
    /**
     
     broadcast message to the app a monitered
     iBeacon was found
     
     */
    
    private func broadCastNotification(beacon: iBeacon) {
        
        let iBeaconDict:[String: iBeacon] = ["iBeacon": beacon]
        
        NotificationCenter.default.post(name: self.iBeaconFoundNotification, object: nil, userInfo: iBeaconDict)
        
    }
    
    // MARK: CoreLocationManagerDelegate
    
    public func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        for beacon in beacons {
            
            for monitoredBeacon in self.iBeaconListToMonitor {
                if ( beacon.major === monitoredBeacon.major ) && ( beacon.minor === monitoredBeacon.minor ) {
                    broadCastNotification(beacon: monitoredBeacon)
                }
            }
            
            if lastBeaconRead.major.compare(beacon.major) == ComparisonResult.orderedSame &&
                lastBeaconRead.minor.compare(beacon.minor) == ComparisonResult.orderedSame &&
                lastBeaconRead.uuid.uuidString == beacon.proximityUUID.uuidString
            {
                
                // if same beacon read
                // check if there is any changes on behaviour
                
                if (lastBeaconRead.proximity != beacon.proximity) {
                    
                    // post to server is user get closer os distant from beacon
                    updateLastBeaconRead(ibeacon: beacon)
                    let parameter = createParametersString(app: appUUID, device: getDeviceUniqueId(), ibeacon: lastBeaconRead)
                    checkConnectionAndPostBeaconStatusToServer(parameters: parameter)
                    
                } else {
                    
                    // if same beacons check if last read is greather
                    // than a minute, post to service is user stays in location
                    // longer
                    if lastBeaconRead.datetime.addingTimeInterval(60).compare(NSDate() as Date) == ComparisonResult.orderedAscending
                    {
                        updateLastBeaconRead(ibeacon: beacon)
                        // post ibeacon when no changes happens after a minute
                        let parameter = createParametersString(app: appUUID, device: getDeviceUniqueId(), ibeacon: lastBeaconRead)
                        checkConnectionAndPostBeaconStatusToServer(parameters: parameter)
                    }
                }
            }
            else
            {
                lastBeaconRead.major = beacon.major
                lastBeaconRead.minor = beacon.minor
                lastBeaconRead.uuid = beacon.proximityUUID as NSUUID
                updateLastBeaconRead(ibeacon: beacon)
                
                // post ibeacon to server when new ibeacon is found
                let parameter = createParametersString(app: appUUID, device: getDeviceUniqueId(), ibeacon: lastBeaconRead)
                checkConnectionAndPostBeaconStatusToServer(parameters: parameter)
            }
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        //print("didStartMonitoringFor")
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // only stop service on location update if there is internet connection to update uuid and region
        if Reachability.isInternetAvailable() == true {
            stopMonitoring()
            let location: CLLocation = locations[0] as CLLocation
            let paramaters = createParametersString(app: self.appUUID, device: getDeviceUniqueId(), latitude: String(location.coordinate.latitude), longitude: String(location.coordinate.longitude))
            postUserLocationToServer(parameters: paramaters)
        }
        
    }
    
}

public class HttpRequest {
    
    /**
     execute post request
     - parameter url: service url
     - parameter parameters: string containing all parameters to send to service
     - returns: void
     */
    
    public class func post(url: String, parameters: String, completion: @escaping (_ response: String) -> ()) -> Void {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "POST"
        request.httpBody = parameters.data(using: .utf8)
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion("error=\(String(describing: error))")
                return
            }
            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                completion("statusCode should be 200, but is \(httpStatus.statusCode)")
            }
            
            let responseString = String(data: data, encoding: .utf8)
            completion(responseString!)
        }
        task.resume()
    }
    
}

public class Reachability {
    
    /**
     check if device have internet conection
     - returns: true if is connected to internet
     */
    
    public class func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
}
