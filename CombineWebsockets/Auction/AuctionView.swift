//
//  Auction.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 20/04/2025.
//

import SwiftUI
import Combine
import Foundation

struct AuctionView: View {
    @State private var webSocketService = WebSocketService(endpoint: "auction")
    @State private var currentBid: AuctionBid?
    @State private var timeRemaining: Int = 120
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var cancellables = Set<AnyCancellable>()
    @State private var decoder = JSONDecoder()
    
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        VStack {
            Text(formattedTimeRemaining)
                .font(.system(.title, design: .monospaced))
                .foregroundColor(timeRemaining < 30 ? .red : .primary)
                .padding()
            
            Image("monalisa")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .padding()
            
            if let bid = currentBid {
                VStack(spacing: 12) {
                    Text("Current Bid: $\(bid.amount, specifier: "%.2f")")
                        .font(.title)
                    
                    Text("\(timeRemaining > 0 ? "Bidder" : "Winner"): \(bid.bidder)")
                        .font(.headline)
                        .foregroundStyle(timeRemaining > 0 ? .primary : .green)
                    
                    Text("Last Updated: \(bid.timestamp, style: .relative)")
                        .font(.caption)
                }
                .padding()
                .transition(.scale.combined(with: .opacity))
            }
        }
        .onAppear {
            timer.connect().store(in: &cancellables)
            
            timer.sink { _ in
                if timeRemaining > 0 {
                    timeRemaining -= 1
                }
            }.store(in: &cancellables)
            
            webSocketService.publisher
                .receive(on: RunLoop.main)
                .decode(type: AuctionBid.self, decoder: decoder)
                .sink(receiveCompletion: {
                    print($0)
                }, receiveValue: { bid in
                    withAnimation {
                        currentBid = bid
                        timeRemaining = bid.timeRemaining
                    }
                })
                .store(in: &cancellables)
        }
    }
}
