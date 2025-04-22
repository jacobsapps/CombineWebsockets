//
//  GameState.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 22/04/2025.
//

import SwiftUI
import Combine

struct GameView: View {
    let webSocketService = WebSocketService.getOrCreateInstance(endpoint: "game")
    @State private var currentGame: GameState?
    @State private var cancellables = Set<AnyCancellable>()
    private let decoder = JSONDecoder()
    
    var body: some View {
        Canvas { context, size in
            guard let characters = currentGame?.characters else { return }
            
            for character in characters {
                let point = CGPoint(
                    x: normalize(character.x, in: UIScreen.main.bounds.width),
                    y: normalize(character.y, in: UIScreen.main.bounds.height)
                )
                
                let resolved = context.resolve(
                    Text(character.emoji)
                        .font(.system(size: 40))
                )
                context.draw(resolved, at: point)
            }
        }
        .animation(.easeInOut(duration: 0.25), value: currentGame?.characters)
        .background(Image("game")
            .resizable()
            .scaledToFill()
        )
        .ignoresSafeArea()
        .onAppear {
            webSocketService.publisher
                .decode(type: GameState.self, decoder: decoder)
                .receive(on: RunLoop.main)
                .removeDuplicates(by: { $0 == $1 })
                .filter { !$0.characters.isEmpty }
                .sink(
                    receiveCompletion: { print($0) },
                    receiveValue: { state in
                        currentGame = state
                    }
                )
                .store(in: &cancellables)
        }
    }
    
    private func normalize(_ value: Double, in max: CGFloat) -> CGFloat {
        CGFloat(value / 1000) * max
    }
}
