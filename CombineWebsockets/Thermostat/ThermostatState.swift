//
//  ThermostatState.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 20/04/2025.
//

import Foundation

struct ThermostatState: Codable {
    let angle: Double
    let deviceName: String
    let temperature: Double
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case angle
        case deviceName = "device_name"
        case temperature
        case timestamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        angle = try container.decode(Double.self, forKey: .angle)
        deviceName = try container.decode(String.self, forKey: .deviceName)
        temperature = try container.decode(Double.self, forKey: .temperature)
        let timestampString = try container.decode(String.self, forKey: .timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        guard let date = formatter.date(from: timestampString) else {
            throw DecodingError.dataCorruptedError(forKey: .timestamp, in: container, debugDescription: "Invalid date format")
        }
        timestamp = date
    }
}

