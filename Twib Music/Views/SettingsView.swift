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
        VStack(alignment: .center) {
            Text("Cache Size: \(storageManager.cacheSize) MB")
                .font(.custom("Helvetica", size: 24))
                .padding(.bottom, 6)
                .foregroundColor(.white)
            Text("Download Size: \(storageManager.songDownloadsSize) MB")
                .font(.custom("Helvetica", size: 24))
                .foregroundColor(.white)
            if storageManager.busy {
                Text("Cannot make changes to storage while downloading songs. Please wait until downloads are complete.")
                    .font(.custom("Helvetica", size: 24))
                    .italic()
                    .foregroundColor(.yellow)
                    .frame(width: 300, height: 151)
                    .padding(.bottom, -14)
            } else {
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
            Text("Liking the App? Consider giving\nTwib's project a star on GitHub!")
                .font(.custom("Helvetica", size: 18))
                .padding(.top, 36)
                .foregroundColor(.white)
            Button("https://github.com/ohhh25/Twib-Music", systemImage: "link") {
                UIApplication.shared.open(URL(string: "https://github.com/ohhh25/Twib-Music")!)
            }
            .padding(.top, 6)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
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
