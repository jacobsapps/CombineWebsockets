//
//  GameState.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 22/04/2025.
//

import Foundation

struct GameState: Codable, Equatable {
    struct GameCharacter: Codable, Equatable {
        let name:   String
        let emoji: String
        let x: Double
        let y: Double
    }
    
    let characters: [GameCharacter]
}
