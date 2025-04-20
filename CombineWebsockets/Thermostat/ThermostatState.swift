//
//  ThermostatState.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 20/04/2025.
//

import Foundation

struct ThermostatState: Codable {
    let angle: Double
    let speed: Double
    let deviceId: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case angle
        case speed
        case deviceId = "device_id"
        case timestamp
    }
}

