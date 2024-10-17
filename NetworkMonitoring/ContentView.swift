//
//  ContentView.swift
//  NetworkMonitoring
//
//  Created by James Afonja on 10/16/24.
//

import SwiftUI
import Combine
import Network

class ViewModel: ObservableObject {
    @Published var networkStatus: NWPath.Status = .satisfied
    private var cancellables = Set<AnyCancellable>()
        
    init() {
        self.monitorNetwork()
    }
    
    func monitorNetwork() {
        NWPathMonitor()
            .publisher(queue: .networkMonitorQueue)
            .receive(on: RunLoop.main)
            .sink { [weak self] status in
                self?.networkStatus = status
            }
            .store(in: &cancellables)
    }
    
    var networkStatusText: String {
        networkStatus == .satisfied ? "Connected to network" : "No network connection"
    }
}

struct ContentView: View {
    @StateObject var viewModel: ViewModel = ViewModel()
    
    var body: some View {
        Text(viewModel.networkStatusText)
    }
    
    
}

#Preview {
    ContentView()
}
