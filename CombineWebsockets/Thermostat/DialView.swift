//
//  DialView.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 20/04/2025.
//

import SwiftUI
import Combine

struct DialView: View {
    let webSocketService = WebSocketService.getOrCreateInstance(endpoint: "thermostat")
    @AppStorage("maxTemperature") private var maxTemperature: Double = 37
    @State private var showOverheatWarning = false
    @State private var currentState: ThermostatState?
    @State private var cancellables = Set<AnyCancellable>()
    private let decoder = JSONDecoder()
    
    private let minTemp = 10.0
    private let maxTemp = 50.0
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .shadow(color: .white, radius: 8, x: -8, y: -8)
                .shadow(color: .gray, radius: 8, x: 8, y: 8)
                .frame(width: 300, height: 300)
            
            if let state = currentState {
                ForEach(0..<180) { degree in
                    Rectangle()
                        .fill(
                            isMarkerActive(degree: Double(degree), currentAngle: state.angle)
                            ? color(for: tempForDegree(Double(degree)))
                            : Color.gray.opacity(0.3)
                        )
                        .frame(width: degree % 15 == 0 ? 3 : 1, height: 8)
                        .offset(y: -140)
                        .rotationEffect(.degrees(Double(degree)))
                        .rotationEffect(.degrees(-90))
                }
                
                ForEach([10, 20, 30, 40], id: \.self) { temp in
                    Text("\(temp)°")
                        .font(.caption2)
                        .offset(y: -120)
                        .rotationEffect(.degrees(Double((temp - 10) * 6)))
                        .rotationEffect(.degrees(-90))
                }
                
                VStack(spacing: .zero) {
                    Text(String(format: "%.1f°", state.temperature))
                        .font(.system(size: 42, weight: .medium, design: .rounded))
                        .foregroundStyle(color(for: state.temperature))
                    
                    Text("Connected to")
                        .font(.caption2)
                        .fontWeight(.medium)
                    Text(state.deviceName)
                        .fontDesign(.monospaced)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Rectangle()
                    .fill(color(for: state.temperature))
                    .frame(width: 4, height: 75)
                    .offset(y: -95)
                    .rotationEffect(.degrees(state.angle))
                    .rotationEffect(.degrees(-90))
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Max Temperature Limit")
                    .font(.headline)
                
                HStack {
                    Slider(value: $maxTemperature, in: minTemp...maxTemp, step: 1)
                        .tint(color(for: maxTemperature))
                    Text("\(Int(maxTemperature))°")
                        .frame(width: 40, alignment: .trailing)
                        .font(.subheadline)
                }
                
                if showOverheatWarning {
                    Text("⚠️ Can't raise temperature above your limit.")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            webSocketService.publisher
                .decode(type: ThermostatState.self, decoder: decoder)
                .receive(on: RunLoop.main)
                .throttle(for: .seconds(0.25), scheduler: RunLoop.main, latest: true)
                .sink(receiveCompletion: { print($0) },
                      receiveValue: { state in
                    if state.temperature > maxTemperature {
                        showOverheatWarning = true
                    } else {
                        withAnimation(.spring()) {
                            currentState = state
                        }
                    }
                })
                .store(in: &cancellables)
        }
    }
    
    private func tempForDegree(_ degree: Double) -> Double {
        let degreesInDial = 180.0
        let tempRange = maxTemp - minTemp
        let normalized = degree / degreesInDial
        return minTemp + (normalized * tempRange)
    }
        
    private func color(for temp: Double) -> Color {
        switch temp {
        case ...15: return .blue
        case ...25: return .yellow
        case ...35: return .orange
        default: return .red
        }
    }
    
    private func isMarkerActive(degree: Double, currentAngle: Double) -> Bool {
        degree <= currentAngle
    }
}
