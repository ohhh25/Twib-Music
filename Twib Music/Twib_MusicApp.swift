//
//  Twib_MusicApp.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/3/24.
//

import SwiftUI
import SpotifyiOS

@main
struct Twib_MusicApp: App {
    var body: some Scene {
        WindowGroup {
            HomeView()
                .onOpenURL { url in
                    handleOpenURL(url)
                }
        }
    }
}

func handleOpenURL(_ url: URL) {
    guard url.scheme == "twib-music" else {
        return
    }
    
    if url.host == "spotify-login-callback" {
        SpotifyManager.handleOpenUrl(url)
    }
}

