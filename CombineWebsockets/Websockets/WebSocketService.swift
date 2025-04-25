//
//  WebSocketService.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 17/04/2025.
//

import Foundation
import Combine

protocol WebSocketService {
    var publisher: AnyPublisher<Data, Error> { get }
}

final class WebSocketServiceImpl: WebSocketService {
    private static var instances: [String: WebSocketService] = [:]
    private static let lock = NSLock()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let dataSubject = PassthroughSubject<Data, Error>()

    var publisher: AnyPublisher<Data, Error> {
        dataSubject.eraseToAnyPublisher()
    }

    static func getOrCreateInstance(endpoint: String) -> WebSocketService {
        lock.lock()
        defer { lock.unlock() }

        if let existing = instances[endpoint] {
            return existing
        }

        let newInstance = WebSocketServiceImpl(endpoint: endpoint)
        instances[endpoint] = newInstance
        return newInstance
    }
    
    private init(endpoint: String) {
        // Run `ipconfig getifaddr en0` to get IP address of the local server
        // Simulators or paired iPhones don't share localhost with your Mac
        let url = URL(string: "ws://192.168.0.83:8000")?.appendingPathComponent(endpoint)
        setupWebSocket(url: url!)
    }
    
    private func setupWebSocket(url: URL) {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        
        Task {
            while true {
                try await receiveNextMessage()
            }
        }
    }

private func receiveNextMessage() async throws {
    guard let webSocketTask else { return }
    
    do {
        let message = try await webSocketTask.receive()
        switch message {
        case .string(let string):
            dataSubject.send(string.data(using: .utf8) ?? Data())
        case .data(let data):
            dataSubject.send(data)
        @unknown default:
            break
        }
    } catch {
        dataSubject.send(completion: .failure(error))
        throw error
    }
}
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    deinit {
        disconnect()
    }
}
