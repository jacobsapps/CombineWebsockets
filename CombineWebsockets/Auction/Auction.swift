//
//  Auction.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 17/04/2025.
//

import Foundation

struct AuctionBid: Codable {
    let bidder: String
    let amount: Double
    let timestamp: Date
    let timeRemaining: Int
    
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        bidder = try container.decode(String.self, forKey: .bidder)
        let rawAmount = try container.decode(Double.self, forKey: .amount)
        amount = (rawAmount * 100).rounded() / 100
        timeRemaining = try container.decode(Int.self, forKey: .timeRemaining)
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
    
    enum CodingKeys: String, CodingKey {
        case bidder, amount, timestamp, timeRemaining
    }
}
