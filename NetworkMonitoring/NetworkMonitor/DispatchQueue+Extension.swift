//
//  DispatchQueue+Extension.swift
//  NetworkMonitoring
//
//  Created by James Afonja on 10/17/24.
//

import Foundation

extension DispatchQueue {
    /// Dedicated queue to handle concurrency reqs for NWPathMonitor.
    static let networkMonitorQueue = DispatchQueue(label: "network.monitor.queue")
}
