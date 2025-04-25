//
//  GameState.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 22/04/2025.
//

import SwiftUI
import Combine

struct GameView: View {
    let webSocketService: WebSocketService
    @State private var currentGame: GameState?
    @State private var cancellables = Set<AnyCancellable>()
    @State private var hasStarted = false
    private let decoder = JSONDecoder()
    
    init(webSocketService: WebSocketService = WebSocketServiceImpl.getOrCreateInstance(endpoint: "game")) {
        self.webSocketService = webSocketService
    }
    
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
            guard !hasStarted else { return }
            hasStarted = true
            
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

#Preview {
    GameView(webSocketService: MockWebsocketService(characters: [
        .init(name: "Mage", emoji: "🧙‍♂️", x: 100, y: 200),
        .init(name: "Warrior", emoji: "⚔", x: 400, y: 300),
        .init(name: "Rogue", emoji: "🧝‍♀️", x: 200, y: 100),
        .init(name: "Archer", emoji: "🏹", x: 500, y: 400)
    ]))
}

struct MockWebsocketService: WebSocketService {
    let publisher: AnyPublisher<Data, Error>
    
    init(characters: [GameState.GameCharacter]) {
        let state = GameState(characters: characters)
        let data = try! JSONEncoder().encode(state)
        self.publisher = Just(data)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}
