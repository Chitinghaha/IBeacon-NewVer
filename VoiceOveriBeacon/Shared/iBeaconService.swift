//
//  iBeaconService.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/1.
//

import Foundation
import CoreLocation

class iBeaconService: NSObject, CLLocationManagerDelegate {
    
    static let shared = iBeaconService()
    
    let locationManager = CLLocationManager()
    var beaconRegions: [CLBeaconRegion] = []
    
    override init() {
        super.init()
        
        self.locationManager.delegate = self
        
        // 檢查是否支援iBeacon
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            if CLLocationManager.isRangingAvailable() {
                let uuid = UUID(uuidString: iBeaconInfos.UUID)!

                // 啟動位置服務
                self.locationManager.requestAlwaysAuthorization()
                
                // 創建iBeacon的Region，用你的iBeacon的UUID、Major和Minor值替換下面的值
//                let beacon1Region = CLBeaconRegion(uuid: uuid, major: 1, minor: 1, identifier: "障礙1")
                
//                let beacon2Region = CLBeaconRegion(uuid: uuid, major: 1, minor: 2, identifier: "障礙2")
                let region = CLBeaconRegion(proximityUUID: uuid, identifier: "iBeacon Region")

                
                self.beaconRegions.append(region)
//                self.beaconRegions.append(beacon2Region)
                
                // 開始監測iBeacon設備
                for region in self.beaconRegions {
                    self.locationManager.startMonitoring(for: region)
                }
                
                // 開始範圍查找iBeacon設備
                for region in beaconRegions {
                    let constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
//                    self.locationManager.startRangingBeacons(satisfying: constraint)
                    self.locationManager.startMonitoring(for: region)
                    print("startRangingBeacons:\(region)")
                }
            }
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location manager did fail: \(error.localizedDescription)")
    }
    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Location manager monitoring did fail: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid)

        // 在這裡做一些進入 region 的處理，例如提供一些提示
        guard CLLocationManager.isRangingAvailable() else { return }
        // 既然進入 region 了，那就偵測跟裝置的距離
        manager.startRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid)

        // 在這裡做一些離開 region 的處理，例如提供一些提示
        guard CLLocationManager.isRangingAvailable() else { return }
        // 既然離開 region 了，那就停止偵測跟裝置的距離
        manager.stopRangingBeacons(satisfying: constraint)
    }
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 開始偵測範圍之後，就先檢查目前的 state 是否在範圍內
        manager.requestState(for: region)
        print("didStartMonitoringFor:\(region)")
    }
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
        
        if state == .inside { // 在範圍內
            if CLLocationManager.isRangingAvailable() {
                manager.startRangingBeacons(satisfying: constraint)
            }
        } else if state == .outside { // 在範圍外
            if CLLocationManager.isRangingAvailable() {
                manager.stopRangingBeacons(satisfying: constraint)
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location manager ranging beacons did fail: \(error.localizedDescription)")
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // beacons 是一個 array，裡頭的 beacon 由近到遠排序
        print("beacons:\(beacons)")
        if let beacon = beacons.first {
            // 取得距離最近的 beacon 了，作些事情吧
        }
    }
}
