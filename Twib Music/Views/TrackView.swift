//
//  TrackView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import SwiftUI

struct TrackView: View {
    @StateObject var playlist: Playlist
    @State var isPlaying = false
    
    var body: some View {
        HStack(alignment: .bottom) {
            VStack(alignment: .leading) {
                Button("", systemImage: isPlaying ? "pause.circle" : "play.circle") {
                    isPlaying.toggle()
                }
                .font(.custom("Helvetica", size: 48))
                Text("\(playlist.tracks.count) songs")
                    .font(.custom("Helvetica", size: 12))
                    .italic()
                    .padding(.trailing, 24)
            }
                .padding(.leading, 24)
            Spacer()
            AsyncImage(url: URL(string: playlist.image_url)) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
                .frame(width: 128, height: 128)
                .padding(.trailing, 24)
        }
            .frame(height: 128)
            .padding(.bottom, 6)
        .toolbar {
            Text(playlist.name)
                .font(.custom("Helvetica", size: 16))
                .fontWeight(.medium)
                .frame(height: 48)
                .lineLimit(2)
        }
        List(playlist.tracks) {track in
            HStack {
                AsyncImage(url: URL(string: track.image_url)) { image in
                    image
                        .resizable()
                } placeholder: {
                    ProgressView()
                }
                    .frame(width: 48, height: 48)
                HStack {
                    VStack(alignment: .leading) {
                        Text(track.name)
                            .font(.custom("Helvetica", size: 16))
                            .padding(.bottom, 2)
                            .lineLimit(1)
                        Text(track.artist)
                            .font(.custom("Helvetica", size: 12))
                            .fontWeight(.light)
                            .lineLimit(1)
                    }
                    .padding(.leading, 12)
                    Spacer()
                    Menu{
                        Button("djfk", action: someFunction)
                    } label: {
                        Label("", systemImage: "ellipsis")
                    }
                }
                Spacer()
            }
        }
        .onAppear() {
            print(playlist.description)
            let url = playlist.tracks_url + "?limit=50"
            if playlist.tracks.isEmpty {
                if playlist is Twib_Music.Album {
                    SpotifyAPI.fetchTracks(playlist, url: playlist.tracks_url)
                }
                else {
                    SpotifyAPI.fetchTracks(playlist, url: url)
                }
            }
        }
    }
}

func someFunction() {
        print("Hello, World!")
    }

