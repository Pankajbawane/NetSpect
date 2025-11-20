//
//  ChartsView.swift
//  NewApp
//
//  Created by Pankaj Bawane on 11/07/25.
//

import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    
    let data: [NWLogItem]
    
    var statusCode: [ChartParameter<Int>] {
        NWChartItemFactory.get(items: data, key: \.statusCode)
    }
    
    var httpMethod: [ChartParameter<String>] {
        NWChartItemFactory.get(items: data, key: \.method)
    }
    
    var hosts: [ChartParameter<String>] {
        NWChartItemFactory.get(items: data, key: \.host)
    }
    
    var body: some View {
        ScrollView {
            VStack {
                Text("Status Code")
                    .font(.caption)
                    .fontWeight(.bold)
                StatusCodeChartView(data: statusCode)
                Text("HTTP Method")
                    .font(.caption)
                    .fontWeight(.bold)
                HTTPMethodPieChartView(data: httpMethod)
                Text("Host")
                    .font(.caption)
                    .fontWeight(.bold)
                HostsChartView(data: hosts)
            }
        }
    }
}

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

struct StatusCodeChartView: View {
    
    let data: [ChartParameter<Int>]
    
    var body: some View {
        Chart(data) {
            BarMark(
                x: .value("Status Code", $0.stringValue == "0" ? "Unknown" : $0.stringValue),
                y: .value("Count", $0.count)
            )
            .foregroundStyle(by: .value("Status Code", $0.stringValue == "0" ? "Unknown" : $0.stringValue))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 300)
        .padding()
    }
}

struct HTTPMethodPieChartView: View {
    let data: [ChartParameter<String>]

    var body: some View {
        Chart(data) {
            SectorMark(
                angle: .value("Count", $0.count),
                innerRadius: .ratio(0.4),
                angularInset: 1
            )
            .foregroundStyle(by: .value("HTTP Method", $0.value))
        }
        .frame(height: 300)
        .padding()
    }
}


struct HostsChartView: View {
    
    let data: [ChartParameter<String>]
    
    var body: some View {
        Chart(data) {
            BarMark(
                x: .value("Hosts", $0.value),
                y: .value("Count", $0.count)
            )
            .foregroundStyle(by: .value("Hosts", $0.value))
        }
        .chartYAxis {
            AxisMarks(position: .leading)
        }
        .frame(height: 300)
        .padding()
    }
}
