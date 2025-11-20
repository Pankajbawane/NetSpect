//
//  ChartsView.swift
//  NewApp
//
//  Created by Pankaj Bawane on 11/07/25.
//

import Foundation

struct NWChartItemFactory {
    
    static func get<T: Hashable>(items: [NWLogItem], key: (NWLogItem) -> T) -> [ChartParameter<T>] {
        return createList(from: items, key: key)
    }
    
    private static func createList<T: Hashable>(from items: [NWLogItem], key: (NWLogItem) -> T) -> [ChartParameter<T>] {
        let grouped = Dictionary(grouping: items, by: key)
        
        let parameters = grouped.map { (code, group) in
            ChartParameter(value: code, count: group.count)
        }
        
        return parameters.sorted { $0.stringValue < $1.stringValue }
    }
}

struct ChartParameter<T: Hashable>: Identifiable {
    let value: T
    let count: Int
    var id: T { value }
    var stringValue: String { "\(value)" }
}
