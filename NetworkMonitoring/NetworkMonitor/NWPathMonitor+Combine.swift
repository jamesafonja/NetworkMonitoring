//
//  NetworkMonitor+Combine.swift
//  NetworkMonitoring
//
//  Created by James Afonja on 10/16/24.
//

import Combine
import Network

extension NWPathMonitor {
    class NetworkStatusSubscription<S: Subscriber>: Subscription where S.Input == NWPath.Status {
        private let subscriber: S?
        private let monitor: NWPathMonitor
        private let queue: DispatchQueue
        
        init(subscriber: S, monitor: NWPathMonitor, queue: DispatchQueue) {
            self.subscriber = subscriber
            self.monitor = monitor
            self.queue = queue
        }
        
        func request(_ demand: Subscribers.Demand) {
            monitor.pathUpdateHandler = { [weak self] path in
                guard let self = self else { return }
                _ = self.subscriber?.receive(path.status)
            }
            
            monitor.start(queue: queue)
        }
        
        func cancel() {
            monitor.cancel()
        }
        
    }
}

extension  NWPathMonitor {
    struct NetworkStatusPublisher: Publisher {
        typealias Output = NWPath.Status
        typealias Failure = Never
        
        private let monitor: NWPathMonitor
        private let queue: DispatchQueue
        
        init(monitor: NWPathMonitor, queue: DispatchQueue) {
            self.monitor = monitor
            self.queue = queue
        }
        
        func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, NWPath.Status == S.Input {
            let subscription
                = NetworkStatusSubscription(
                    subscriber: subscriber,
                    monitor: monitor,
                    queue: queue
                )
            
            subscriber.receive(subscription: subscription)
        }

    }
    
    func publisher(queue: DispatchQueue) -> NWPathMonitor.NetworkStatusPublisher {
        return NetworkStatusPublisher(monitor: self, queue: queue)
    }
}

// MARK: - Sample Usage
/*
 import SwiftUI
 import Combine
 import Network

 class ViewModel: ObservableObject {
     private var cancellables = Set<AnyCancellable>()
     private let monitorQueue = DispatchQueue(label: "monitor")
     
     // 1
     @Published var networkStatus: NWPath.Status = .satisfied
     
     init() {
         // 2
         NWPathMonitor()
             .publisher(queue: monitorQueue)
             .receive(on: DispatchQueue.main)
             .sink { [weak self] status in
                 self?.networkStatus = status
             }
             .store(in: &cancellables)
     }
 }

 struct ContentView: View {
     // 3
     @ObservedObject var viewModel = ViewModel()
     
     var body: some View {
         // 4
         Text(viewModel.networkStatus == .satisfied ?
              "Connection is OK" : "Connection lost"
             )
             .padding()
     }
 }
 */
