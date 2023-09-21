//
//  iBeaconInfos.swift
//  VoiceOveriBeacon
//
//  Created by 陳邦亢 on 2023/9/1.
//
import Foundation
import CoreLocation

enum iBeaconType: Int {
    case normal = 0
    case obstacle = 1
}

struct iBeaconModel: Codable, Equatable {
    let uuidString: String
    let major: Int
    let minor: Int
    let description: String
    let name: String
    // 種類：0 = 正常, 1 = 障礙物
    let rawType: Int
    // an unique ID
    let id: Int
    
    let canBeDestination: Bool?
    
    let intersectionInfo: [iBeaconEdge]?
    /// unknown = 0
    /// immediate = 1
    /// near = 2
    /// far = 3
    var proximity: Int?
    
    var uuid: UUID { get {
        UUID(uuidString: self.uuidString) ?? UUID(uuidString: iBeaconConstants.defaultUUID)!
    }}
    
    var type: iBeaconType { get {
        iBeaconType(rawValue: self.rawType) ?? .normal
    }}
    
    static func == (lhs: iBeaconModel, rhs: iBeaconModel) -> Bool {
        // Define your equality logic here
        return lhs.uuidString == rhs.uuidString &&
        lhs.major == rhs.major &&
        lhs.minor == rhs.minor
    }
}

struct iBeaconEdge: Codable {
    let nodeID: Int
    let description: String
}
