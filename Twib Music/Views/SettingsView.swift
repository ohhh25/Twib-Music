//
//  SettingsView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/26/24.
//

import SwiftUI

struct SettingsView: View {
    @StateObject private var storageManager = StorageManager
    var body: some View {
        VStack {
            Text("Cache Size: \(storageManager.cacheSize) MB")
                .font(.custom("Helvetica", size: 24))
                .padding(.bottom, 6)
            Text("Download Size: \(storageManager.songDownloadsSize) MB")
                .font(.custom("Helvetica", size: 24))
            Group {
                Button("Remove Cache") {
                    do { try StorageManager.clearCache() }
                    catch { print("Error clearing cache: \(error)") }
                }
                Button("Remove ALL Downloads") {
                    do { try StorageManager.clearDownloads() }
                    catch { print("Error removing downloads: \(error)") }
                }
            }
            .disabled(storageManager.busy)
            .font(.custom("Helvetica", size: 18))
            .foregroundColor(.white)
            .padding(EdgeInsets(top: 14, leading: 28, bottom: 14, trailing: 28))
            .background(Color.orange)
            .cornerRadius(32)
            .padding(.top, 24)
        }
        .onAppear {
            do {
                try StorageManager.syncCacheSize()
                try StorageManager.syncDownloadsSize()
            } catch {
                print("Error syncing cache size: \(error)")
            }
        }
    }
}

#Preview {
    SettingsView()
}
