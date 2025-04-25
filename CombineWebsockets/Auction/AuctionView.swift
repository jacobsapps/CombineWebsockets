import SwiftUI
import Combine
import Charts
import Foundation

struct AuctionView: View {
    let webSocketService = WebSocketServiceImpl.getOrCreateInstance(endpoint: "auction")
    @State private var highestBid: AuctionBid?
    @State private var bidHistory: [AuctionBid] = []
    @State private var timeRemaining: Int = 120
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var cancellables = Set<AnyCancellable>()
    @State private var hasStarted = false
    private let decoder = JSONDecoder()

    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }

    var body: some View {
        HStack {
            VStack {
                Image("monalisa")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 250)

                Text(formattedTimeRemaining)
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(timeRemaining < 30 ? .red : .primary)
            }

            VStack {
                if let bid = highestBid {
                    VStack(spacing: 12) {
                        Text("Current Bid: $\(bid.amount, specifier: "%.2f")")
                            .font(.title)

                        Text("\(timeRemaining > 0 ? "Bidder" : "Winner"): \(bid.bidder)")
                            .font(.headline)
                            .foregroundStyle(timeRemaining > 0 ? Color.primary : Color.green)
                    }
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                }
                
                Chart(bidHistory) { bid in
                    LineMark(
                        x: .value("Time", bid.timestamp),
                        y: .value("Bid Amount", bid.amount)
                    )
                    .interpolationMethod(.catmullRom)
                    .foregroundStyle(.blue)
                }
                .frame(width: 300, height: 200)
            }
        }
        .padding()
        .onAppear {
            guard !hasStarted else { return }
            hasStarted = true
            
            timer.connect().store(in: &cancellables)
            
            timer.sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }.store(in: &cancellables)
            
            webSocketService.publisher
                .buffer(size: 1, prefetch: .keepFull, whenFull: .dropOldest)
                .compactMap { data -> AuctionBid? in
                    try? decoder.decode(AuctionBid.self, from: data)
                }
                .scan([]) { (history: [AuctionBid], newBid) in
                    history + [newBid]
                }
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { bids in
                    withAnimation {
                        bidHistory = bids
                        highestBid = bids.last
                        timeRemaining = bids.last?.timeRemaining ?? 0
                    }
                })
                .store(in: &cancellables)
        }
    }
}
