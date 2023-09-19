//
//  iBeaconViewModel.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/2.
//

import Foundation
import CoreLocation

class iBeaconViewModel {
    
    static let shared = iBeaconViewModel()
    
    var ibeacons: [iBeaconModel] = []
    
    init () {
        self.ibeacons = FileReadWriteService.shared.getAlliBeaconInfomation()
//        self.setFakeiBeacons()
    }
    
    func transformToiBeaconModel(from clbeacon: CLBeacon) -> iBeaconModel? {
        var res: iBeaconModel? = nil
        for i in 0..<self.ibeacons.count {
            let ibeacon = self.ibeacons[i]
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
