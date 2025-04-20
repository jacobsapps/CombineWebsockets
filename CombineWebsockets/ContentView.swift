//
//  TabsView.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 17/04/2025.
//

import SwiftUI

struct TabsView: View {
    var body: some View {
        TabView {
            AuctionView()
                .tabItem {
                    Label("Auction", systemImage: "dollarsign.circle")
                }
            
            ThermostatView()
                .tabItem {
                    Label("Thermostat", systemImage: "dial.min")
                }
            
            GameView()
                .tabItem {
                    Label("Game", systemImage: "gamecontroller")
                }
        }
    }
}

#Preview {
    TabsView()
}
