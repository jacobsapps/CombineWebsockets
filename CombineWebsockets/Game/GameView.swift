import SwiftUI
import Combine

struct GameView: View {
    @State private var currentGame: GameState?
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        // TODO: Canvas
//        ForEach(game.characters, id: \.id) { character in
//            Text(character.emoji)
//                .font(.system(size: 40))
//                .position(x: character.position.x, y: character.position.y)
//        }
        Text("Game")
    }
} 
