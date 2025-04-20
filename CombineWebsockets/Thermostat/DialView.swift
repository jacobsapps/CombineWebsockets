import SwiftUI
import Combine

struct ThermostatView: View {
    @State private var currentThermostat: ThermostatState?
    @State private var cancellables = Set<AnyCancellable>()
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.gray.opacity(0.1))
                .shadow(color: .white, radius: 8, x: -8, y: -8)
                .shadow(color: .gray, radius: 8, x: 8, y: 8)
                .frame(width: 300, height: 300)
            
            if let thermostat = currentThermostat {
                VStack {
                    Circle()
                        .stroke(lineWidth: 4)
                        .frame(width: 280, height: 280)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: 4, height: 140)
                        .offset(y: -70)
                        .rotationEffect(.degrees(thermostat.angle))
                    
                    Text("Speed: \(thermostat.speed, specifier: "%.1f")")
                        .font(.caption)
                    
                    Text("Device: \(thermostat.deviceId)")
                        .font(.caption2)
                }
            }
        }
    }
} 
