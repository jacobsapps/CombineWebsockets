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
    let webSocketService = WebSocketServiceImpl.getOrCreateInstance(endpoint: "auction")
    @State private var highestBid: AuctionBid?
    @State private var timeRemaining: Int = 120
    @State private var timer: Timer.TimerPublisher = Timer.publish(every: 1, on: .main, in: .common)
    @State private var cancellables = Set<AnyCancellable>()
    private let decoder = JSONDecoder()
    
    var formattedTimeRemaining: String {
        let minutes = timeRemaining / 60
        let seconds = timeRemaining % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack {
            Image("monalisa")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(height: 300)
                .padding()
            
            VStack {
                Text(formattedTimeRemaining)
                    .font(.system(.title, design: .monospaced))
                    .foregroundColor(timeRemaining < 30 ? .red : .primary)
                    .padding()
                
                if let bid = highestBid {
                    VStack(spacing: 12) {
                        Text("Current Bid: $\(bid.amount, specifier: "%.2f")")
                            .font(.title)
                        
                        Text("\(timeRemaining > 0 ? "Bidder" : "Winner"): \(bid.bidder)")
                            .font(.headline)
                            .foregroundStyle(timeRemaining > 0 ? Color.primary : Color.green)
                        
                        Text("Last Updated: \(bid.timestamp, style: .relative)")
                            .font(.caption)
                    }
                    .padding()
                    .transition(.scale.combined(with: .opacity))
                }
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
                .compactMap { data -> AuctionBid? in
                    try? decoder.decode(AuctionBid.self, from: data)
                }
                .buffer(size: 1, prefetch: .keepFull, whenFull: .dropOldest)
            //                .scan([]) { (history: [AuctionBid], newBid) in
            //                    history + [newBid]
            //                }
                .scan(nil) { (highestBidSoFar: AuctionBid?, newBid: AuctionBid) -> AuctionBid? in
                    guard let highestBid = highestBidSoFar else {
                        return newBid
                    }
                    return newBid.amount > highestBid.amount ? newBid : highestBid
                }
                .compactMap { $0 }
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { bid in
                    withAnimation {
                        highestBid = bid
                        timeRemaining = bid.timeRemaining
                    }
                })
                .store(in: &cancellables)
        }
    }
}
