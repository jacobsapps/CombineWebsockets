//
//  GameState.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 20/04/2025.
//

import Foundation

struct GameState: Codable {
    struct GameCharacter: Codable {
        let emoji: String
        let position: Position
        let velocity: Position
        let id: String
        
        struct Position: Codable {
            let x: Double
            let y: Double
        }
    }
    
    let characters: [GameCharacter]
    let timestamp: Date
}
