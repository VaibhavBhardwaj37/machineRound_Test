//
//  NetworkMonitor.swift
//  MachineRound_Swift
//
//  Created by Sanskar IOS Dev on 16/06/25.
//
import Network

class NetworkMonitor {
    static let shared = NetworkMonitor()
    private let monitor = NWPathMonitor()
    private var isMonitoring = false

    var isConnected: Bool = false

    func startMonitoring() {
        guard !isMonitoring else { return }
        isMonitoring = true
        monitor.pathUpdateHandler = { path in
            self.isConnected = path.status == .satisfied
        }
        let queue = DispatchQueue(label: "NetworkMonitor")
        monitor.start(queue: queue)
    }

    func stopMonitoring() {
        monitor.cancel()
        isMonitoring = false
    }
}

