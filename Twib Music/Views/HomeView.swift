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
        VStack(alignment: .center) {
            // MARK: Standard Views
            HStack {
                Image("cropped")
                    .resizable()
                    .frame(width: 48, height: 48)
                Text("Welcome to Twib Music!")
                    .font(.custom("Helvetica", size: 24))
                    .fontWeight(.bold)
            }
            .padding(.top, 6)
            // MARK: Spotify Connection
            if !spotifyManager.sessionConnected {
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
                Text("Spotify Account Connected!")
                    .font(.custom("Helvetica", size: 16))
                    .padding(.bottom, 6)
                Divider()
                NavigationStack {
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
}

#Preview {
    HomeView()
}
