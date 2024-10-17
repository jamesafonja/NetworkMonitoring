import Combine
import Network

extension NWInterface.InterfaceType: @retroactive CaseIterable {
    public static let allCases: [NWInterface.InterfaceType] = [
        .wifi, .cellular
    ]
}

final class NetworkMonitor: @unchecked Sendable {
    private let monitor: NWPathMonitor

    static let shared = NetworkMonitor()

    private(set) var isConnected = false
    private(set) var isExpensive = false
    private(set) var currentConnectionType: NWInterface.InterfaceType?

    private init() {
        monitor = NWPathMonitor()
    }
}

extension NetworkMonitor {
    enum NetworkMonitorError: Error {
        case noConnection
    }
}

extension NetworkMonitor {
    func startMonitoring() {
        DispatchQueue.networkMonitorQueue.sync { [weak self] in
            self?.monitor.pathUpdateHandler = { [weak self] path in
                self?.isConnected = (path.status != .unsatisfied && path.status != .requiresConnection)
                self?.isExpensive = path.isExpensive
            }
        }
    }

    func stopMonitoring() {
        DispatchQueue.networkMonitorQueue.sync { [weak self] in
            self?.monitor.cancel()
        }
    }
}
