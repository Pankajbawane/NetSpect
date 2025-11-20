//
//  RequestDisplayItem.swift
//  NewApp
//
//  Created by Pankaj Bawane on 19/07/25.
//

import SwiftUI
import Combine

final internal class NetworkLogManager: ObservableObject {
    static let shared = NetworkLogManager()

    @Published var items: [NWLogItem] = []

    private var itemUpdateTask: Task<Void, Never>?

    private init() {
        URLSessionConfiguration.enableNetworkSwizzling()
        startObservingUpdates()
    }

    func add(_ item: NWLogItem) {
        Task.detached {
            await NetworkItemContainer.shared.add(item)
        }
    }

    private func startObservingUpdates() {
        // Listen for changes from the actor
        itemUpdateTask = Task {
            for await updatedItems in await NetworkItemContainer.shared.itemUpdates() {
                await updareItems(items: updatedItems)
            }
        }
    }
    
    @MainActor
    private func updareItems(items: [NWLogItem]) {
        self.items = items
    }

    func cancel() {
        itemUpdateTask?.cancel()
    }
}


fileprivate actor NetworkItemContainer {
    static let shared = NetworkItemContainer()
    private(set) var items: [NWLogItem] = []
    private var cache: [UUID: Int] = [:]

    private var itemContinuation: AsyncStream<[NWLogItem]>.Continuation?

    private init() {}

    // AsyncStream for observing live updates
    func itemUpdates() -> AsyncStream<[NWLogItem]> {
        AsyncStream { continuation in
            self.itemContinuation = continuation
            continuation.yield(items)
        }
    }

    func add(_ item: NWLogItem) {
        if let index = cache[item.id] {
            items[index] = item
        } else {
            cache[item.id] = items.count
            items.append(item)
        }
        itemContinuation?.yield(items)
    }
}

