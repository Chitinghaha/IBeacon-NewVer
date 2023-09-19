//
//  iBeaconViewModel.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/2.
//

import Foundation
import CoreLocation
import Combine

class iBeaconViewModel: NSObject {
    
    private var cancellable = Set<AnyCancellable>()
    private let locationManager = CLLocationManager()
    
    var predefinediBeacons: [iBeaconModel] = []
    
    var rangingiBeacons: [iBeaconModel] = []
    var nearestiBeaconFilterContainer: [Int] = []
    
    @Published var nearestiBeacon: iBeaconModel? = nil
    
    var speechWhenClosing = PassthroughSubject<String, Never>()
    var isDistanceImmediately = PassthroughSubject<Bool, Never>()

    override init () {
        super.init()
        self.predefinediBeacons = FileReadWriteService.shared.getAlliBeaconInfomation()
//        self.setFakeiBeacons()
        
        //        self.testiBeaconBinding()
        self.setupLocationManager()


    }
    
    func updateBeaconInfos(with beacons: [CLBeacon]) {
        self.rangingiBeacons = beacons.compactMap {
            self.transformToiBeaconModel(from: $0)
        }
        
        print("beacons:")
        beacons.forEach {
            print($0)
        }
        
        // 取出最近且不是-1m的ibeacon id 存入filter pool中
        if let clBeacon = beacons.first(where: { $0.accuracy > 0 }),
            let ibeacon = self.transformToiBeaconModel(from: clBeacon) {
            self.nearestiBeaconFilterContainer.append(ibeacon.id)
        }
        else {
            self.nearestiBeaconFilterContainer.append(-1)
        }
        
        
        if (self.nearestiBeaconFilterContainer.count > AppSetting.nearestFilterNum) {
            self.nearestiBeaconFilterContainer.removeFirst()
        }
        
        if (self.nearestiBeaconFilterContainer.last! != -1 &&
            self.nearestiBeaconFilterContainer.first! != self.nearestiBeaconFilterContainer.last! &&
            self.nearestiBeaconFilterContainer.count > 2) {
            self.nearestiBeaconFilterContainer.removeFirst(2)
        }
        

        if (self.nearestiBeaconFilterContainer.count > AppSetting.nearestFilterNum / 3) {
            let idFrequency = self.nearestiBeaconFilterContainer.reduce(into: [:]) {
                counts, id in
                counts[id, default: 0] += 1
            }
            print("pool =\(idFrequency)")
            if let nearestiBeaconID = idFrequency.max(by: { $0.value < $1.value })?.key,
               nearestiBeaconID != -1 {

                self.nearestiBeacon = self.rangingiBeacons.first{ $0.id == nearestiBeaconID }
                
                // 加上距離的publish,去過濾掉已經遠離原本目標的情況
                if let beacon = self.nearestiBeacon,
                   beacon.proximity == 1 {
                    self.speechWhenClosing.send("\(beacon.name)，\(beacon.description)")
                    self.isDistanceImmediately.send(true)
                }
                else {
                    self.isDistanceImmediately.send(false)
                }
            
            }
            else {
                self.nearestiBeacon = nil
            }
        }
    }

    
    func transformToiBeaconModel(from clbeacon: CLBeacon) -> iBeaconModel? {
        var res: iBeaconModel? = nil
        for i in 0..<self.predefinediBeacons.count {
            let ibeacon = self.predefinediBeacons[i]
            if (ibeacon.uuidString.lowercased() == clbeacon.uuid.uuidString.lowercased() && NSNumber(integerLiteral: ibeacon.major) == clbeacon.major && NSNumber(integerLiteral: ibeacon.minor) == clbeacon.minor) {
                res = ibeacon
                let newProximity = iBeaconProximityDefinition.getProximity(distance: clbeacon.accuracy, table: iBeaconProximityDefinition.proximityTable)
                if (res!.proximity == nil || newProximity != 0) {
                    res!.proximity = newProximity
                }
                
                break
            }
        }

        return res
    }
//    
//    func setFakeiBeacons() {
//        self.ibeacons = [
//            iBeaconModel(
//                uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825",
//                major: 1,
//                minor: 1,
//                description: "這是一個測試用的ibeacon說明",
//                name: "麥當勞門口",
//                rawType: 0
//            ),
//            iBeaconModel(
//                uuidString: "fda50693-a4e2-4fb1-afcf-c6eb07647825",
//                major: 1,
//                minor: 2,
//                description: "這也是一個測試用的ibeacon說明",
//                name: "牆柱",
//                rawType: 1
//            )
//        ]
//    }
    
}

extension iBeaconViewModel {
    func testiBeaconBinding() {
//        let speechTimer = Timer.publish(every: 1.0, on: .main, in: .common)
//            .autoconnect()
//            .map { _ in "測試靠近某物" }
            
//        speechTimer
//            .print("speechTimer")
//            .sink { string in
//                self.speechWhenClosing.send(string)
//            }
//            .store(in: &cancellable)
        
        Timer.publish(every: 2.3, on: .current, in: .common)
            .autoconnect()
            .map { _ in Bool.random() }
            .sink {
                self.isDistanceImmediately.send($0)
            }
            .store(in: &cancellable)
        
        Timer.publish(every: 2.5, on: .current, in: .common)
            .autoconnect()
            .sink { _ in
                if var ibeacon = self.predefinediBeacons.randomElement() {
                    ibeacon.proximity = [1,2,3].randomElement()!
                    self.nearestiBeacon = ibeacon
                }
            }
            .store(in: &cancellable)
        
    }

}

extension iBeaconViewModel: CLLocationManagerDelegate {

    func setupLocationManager() {
        self.locationManager.delegate = self
        
        if CLLocationManager.isMonitoringAvailable(for: CLBeaconRegion.self) {
            print("Beacon監控是可用的")
            locationManager.requestAlwaysAuthorization()
            
            let ibeacons = self.predefinediBeacons
            
            
            ibeacons.forEach {
                let constraint = CLBeaconIdentityConstraint(uuid: $0.uuid)
                
                if (!self.locationManager.rangedBeaconConstraints.contains(constraint)) {
                    self.locationManager.startRangingBeacons(satisfying: constraint)
                }
            }
        }else {
            print("Beacon監控不可用")
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
        var constraint: CLBeaconIdentityConstraint
        
        constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
//        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid, major: CLBeaconMajorValue(region.major), minor: CLBeaconMinorValue(region.minor))
        
        AudioPlayerService.shared.playSound(name: SoundEffectConstant.start)
        guard CLLocationManager.isRangingAvailable() else { return }
        print("進入範圍，開始監測距離：\(constraint)")
        if (!manager.rangedBeaconConstraints.contains(constraint)) {
            manager.startRangingBeacons(satisfying: constraint)
        }
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
//        guard region is CLBeaconRegion,
//        let region = region as? CLBeaconRegion,
//        let major = region.major,
//        let minor = region.minor
//        else { return }
//
//        let constraint = CLBeaconIdentityConstraint(uuid: region.uuid, major: CLBeaconMajorValue(truncating: major), minor: CLBeaconMinorValue(truncating: minor))
//        print("離開範圍，解除監測距離:\(region)")
//
//        guard CLLocationManager.isRangingAvailable() else { return }
//
//        manager.stopRangingBeacons(satisfying: constraint)
    }

    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        // 開始偵測範圍之後，就先檢查目前的 state 是否在範圍內
        manager.requestState(for: region)
        print("didStartMonitoringFor:\(region)")
    }

    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        guard region is CLBeaconRegion else { return }
        let region = region as! CLBeaconRegion
        var constraint: CLBeaconIdentityConstraint
        guard CLLocationManager.isRangingAvailable() else { return }

        print("state of region:\(region) = \(state)")
        constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
        if state == .inside { // 在範圍內
            if (!manager.rangedBeaconConstraints.contains(constraint)) {
                manager.startRangingBeacons(satisfying: constraint)
            }
        }
//
//        if let major = region.major,
//           let minor = region.minor {
//            constraint = CLBeaconIdentityConstraint(uuid: region.uuid, major: CLBeaconMajorValue(truncating: major), minor: CLBeaconMinorValue(truncating: minor))
//            print("開始監控範圍 startRangingBeacons, constraint=\(constraint)")
//            if state == .inside { // 在範圍內
//                manager.startRangingBeacons(satisfying: constraint)
//            } else if state == .outside { // 在範圍外
//                manager.stopRangingBeacons(satisfying: constraint)
//            }
//
//        }
//        else {
//            constraint = CLBeaconIdentityConstraint(uuid: region.uuid)
//            if state == .inside { // 在範圍內
//                manager.startRangingBeacons(satisfying: constraint)
//
//            }
//        }
    }

    func locationManager(_ manager: CLLocationManager, rangingBeaconsDidFailFor region: CLBeaconRegion, withError error: Error) {
        print("Location manager ranging beacons did fail: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        // beacons 是一個 array，裡頭的 beacon 由近到遠排序
        
        self.updateBeaconInfos(with: beacons)
        
    }
    
}
