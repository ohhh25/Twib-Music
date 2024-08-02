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
    @StateObject private var interfacer = Interfacer
    
    var body: some View {
        VStack(alignment: .center) {
            // MARK: Standard Views
            HStack {
                Image("cropped")
                    .resizable()
                    .frame(width: 64, height: 64)
                Text("Welcome to Twib Music!")
                    .font(.custom("Helvetica", size: 24))
                    .fontWeight(.bold)
            }
            // MARK: Spotify Connection
            if !spotifyManager.sessionConnected {
                Text("Connect your Spotify account")
                    .font(.custom("Helvetica", size: 18))
                Button("Play TSwift!") {
                    spotifyManager.didTapConnect()
                }
                    .font(.custom("Helvetica", size: 18))
                    .foregroundColor(.white)
                    .padding(EdgeInsets(top: 11.75, leading: 32.0, bottom: 11.75, trailing: 32.0))
                    .background(buttonBackgroundColor)
                    .cornerRadius(20.0)
                    .padding(.top, 12)
            }
            else {
                Text("Spotify Account Connected!")
                    .font(.custom("Helvetica", size: 18))
                List(interfacer.playlists) { playlist in
                    PlaylistView(playlist: playlist)
                }
                .padding(.top, 12)
            }
        }
        .padding()
        Spacer()
    }
}

#Preview {
    HomeView()
}
