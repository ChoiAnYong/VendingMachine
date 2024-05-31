//
//  TcpSocket.swift
//  NetworkProgrammingProject
//
//  Created by 최안용 on 5/29/24.
//

import Foundation
import Network
import Combine

class TcpSocket: ObservableObject {
    private var connection: NWConnection?
    private let queue = DispatchQueue(label: "VendingMachineClientQueue")
    
    @Published var messages: [String] = []
    
    func connect(host: NWEndpoint.Host, port: NWEndpoint.Port) {
        connection = NWConnection(host: host, port: port, using: .tcp)
        
        connection?.stateUpdateHandler = { state in
            switch state {
            case .ready:
                print("Connected to \(host)")
                self.receive()
            case .failed(let error):
                print("Failed to connect: \(error)")
            default:
                break
            }
        }
        
        connection?.start(queue: queue)
    }
    
    func send(message: String) {
        let data = message.data(using: .utf8)
        connection?.send(content: data, completion: .contentProcessed({ error in
            if let error = error {
                print("Failed to send data: \(error)")
                return
            }
            print("Data sent: \(message)")
        }))
    }
    
    private func receive() {
        connection?.receive(minimumIncompleteLength: 1, maximumLength: 1024) { data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                if let message = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.async {
                        self.messages.append(message)
                    }
                }
            }
            
            if isComplete {
                self.connection?.cancel()
            } else if let error = error {
                print("Receive error: \(error)")
            } else {
                self.receive()
            }
        }
    }
    
    func disconnect() {
        connection?.cancel()
    }
}
