//
//  HomeView.swift
//  Twib Music
//
//  Created by Lukas Cao on 7/3/24.
//

import SwiftUI

fileprivate let buttonBackgroundColor = Color(red:(29.0 / 255.0), green:(185.0 / 255.0), blue:(84.0 / 255.0))

struct HomeView: View {
    @StateObject private var spotifyManager = SpotifyManager
    @StateObject private var spotifyAPI = SpotifyAPI
    
    var body: some View {
        // MARK: Spotify Connection
        if !spotifyManager.sessionConnected {
            HeadingView()
            Image("Icon")
                .resizable()
                .padding(.top, 12)
                .scaledToFit()
            Button("Connect Spotify Account") {
                spotifyManager.didTapConnect()
            }
                .font(.custom("Helvetica", size: 18))
                .foregroundColor(.white)
                .padding(EdgeInsets(top: 14, leading: 28, bottom: 14, trailing: 28))
                .background(buttonBackgroundColor)
                .cornerRadius(32)
                .padding(.top, 24)
            Spacer()
        }
        else {
            // MARK: Playlist View
            NavigationStack {
                HeadingView()
                Text("Spotify Account Connected!")
                    .font(.custom("Helvetica", size: 16))
                    .padding(.bottom, 6)
                Divider()
                List(spotifyAPI.playlists) { playlist in
                    NavigationLink {
                        TrackView(playlist: playlist)
                    } label: {
                        PlaylistView(playlist: playlist)
                    }
                }
            }
            .listStyle(.plain)
            Spacer()
        }
    }
}

#Preview {
    HomeView()
}
