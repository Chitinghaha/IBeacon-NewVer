//
//  iBeaconDistanceDefinition.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/15.
//

import Foundation

struct iBeaconProximityDefinition {
    static let proximityTable = [
        proximityRange(range: 0.0..<7.0, proximityDefinition: 1),
        proximityRange(range: 7.0..<20.0, proximityDefinition: 2),
        proximityRange(range: 20.0..<100.0, proximityDefinition: 3),
        proximityRange(range: 100.0..<Double.infinity, proximityDefinition: 0),
        proximityRange(range: -Double.infinity..<0.0, proximityDefinition: 0)
    ]
    
    static let testProximityTable = [
        proximityRange(range: 0.0..<3.0, proximityDefinition: 1),
        proximityRange(range: 3.0..<20.0, proximityDefinition: 2),
        proximityRange(range: 20.0..<100.0, proximityDefinition: 3),
        proximityRange(range: 100.0..<Double.infinity, proximityDefinition: 0),
        proximityRange(range: -Double.infinity..<0.0, proximityDefinition: 0)
    ]
    
    static func getProximity(distance: Double, table: [proximityRange]) -> Int {
        for range in table {
            if range.range.contains(distance) {
                return range.proximityDefinition
            }
        }
        return 0 // 預設為灰色，表示未知
    }
}

struct proximityRange {
    let range: Range<Double>
    
    /// unknown = 0
    /// immediate = 1
    /// near = 2
    /// far = 3
    let proximityDefinition: Int
}
