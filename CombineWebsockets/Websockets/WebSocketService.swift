//
//  WebSocketService.swift
//  CombineWebsockets
//
//  Created by Jacob Bartlett on 17/04/2025.
//

import Foundation
import Combine

final class WebSocketService {
    private static var instances: [String: WebSocketService] = [:]
//    private static let lock = NSLock()
    
    private var webSocketTask: URLSessionWebSocketTask?
    private let dataSubject = PassthroughSubject<Data, Error>()

    var publisher: AnyPublisher<Data, Error> {
        dataSubject.eraseToAnyPublisher()
    }

    static func getOrCreateInstance(endpoint: String) -> WebSocketService {
//        lock.lock()
//        defer { lock.unlock() }

        if let existing = instances[endpoint] {
            return existing
        }

        let newInstance = WebSocketService(endpoint: endpoint)
        instances[endpoint] = newInstance
        return newInstance
    }
    
    private init(endpoint: String) {
        // Run `ipconfig getifaddr en0` to get IP address of the local server
        // Simulators or paired iPhones don't share localhost with your Mac
        let url = URL(string: "ws://192.168.0.7:8000")?.appendingPathComponent(endpoint)
        setupWebSocket(url: url!)
    }
    
    private func setupWebSocket(url: URL) {
        let session = URLSession(configuration: .default)
        webSocketTask = session.webSocketTask(with: url)
        webSocketTask?.resume()
        receiveNextMessage()
    }
    
    private func receiveNextMessage() {
        webSocketTask?.receive { [weak self] result in
            
            defer { self?.receiveNextMessage() }
            
            guard let self = self else { return }
            switch result {
            case .success(let message):
                switch message {
                case .string(let string):
                    dataSubject.send(string.data(using: .utf8) ?? Data())
                case .data(let data):
                    dataSubject.send(data)
                @unknown default:
                    break
                }
                
            case .failure(let error):
                dataSubject.send(completion: .failure(error))
            }
        }
    }
    
    func disconnect() {
        webSocketTask?.cancel(with: .goingAway, reason: nil)
    }
    
    deinit {
        disconnect()
    }
} 
