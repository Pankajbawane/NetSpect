//
//  LogsLandingView.swift
//  NewApp
//
//  Created by Pankaj Bawane on 19/07/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var manager = NetworkLogManager.shared
    @State private var isCallServiceLoaded = false
    @State private var showExportSheet = false
    @State private var exportURL: URL?
    @State private var navigationPath = NavigationPath()

    var body: some View {
        NavigationStack(path: $navigationPath) {
            itemList
                .navigationTitle("Requests")
                .navigationBarTitleDisplayMode(.inline)
                .navigationDestination(for: String.self,
                                       destination: analyticsNavigationDestination)
                .toolbar {
                    analyticsButton
                    exportButton
                }
                .sheet(isPresented: $showExportSheet, content: exportSheet)
                //.fullScreenCover(isPresented: $showExportSheet, content: exportSheet)
                .onAppear(perform: loadServiceIfNeeded)
        }
    }

    private var itemList: some View {
        List($manager.items, id: \.id) { item in
            NavigationLink {
                LogDetailsLandingView(item: item)
            } label: {
                LogListItemView(item: item)
            }
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private func analyticsNavigationDestination(_ path: String) -> some View {
        if path == "analytics" {
            AnalyticsDashboardView(data: manager.items)
        } else if path == "showExport" {
            exportSheet()
        }
    }

    private var analyticsButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button("Analytics") {
                navigationPath.append("analytics")
            }
        }
    }

    private var exportButton: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Button {
                exportData()
            } label: {
                Image(systemName: "square.and.arrow.up")
            }
            .accessibilityLabel("Export")
        }
    }

    private func exportData() {
        exportURL = ExportManager.csv(manager.items).exporter.export()
        //showExportSheet = true
        navigationPath.append("showExport")
    }

    @ViewBuilder
    private func exportSheet() -> some View {
        ExportOptionsView(url: exportURL) { type in
            
        } onCancel: {
            
        }
    }

    private func loadServiceIfNeeded() {
        guard !isCallServiceLoaded else { return }
        _ = CallService()
        isCallServiceLoaded = true
    }
}

#Preview {
    ContentView()
}
