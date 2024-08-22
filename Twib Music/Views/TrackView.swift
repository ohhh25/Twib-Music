//
//  TrackView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import SwiftUI
import UIKit

struct TrackView: View {
    @StateObject var playlist: Playlist
    @State var isPlaying = false
    @State var downloadImage = "arrow.down.circle"
    
    var body: some View {
        // MARK: JUST HEADING
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
            Button("", systemImage: playlist.downloadStatusIcon) {
                playlist.downloadTracks()
            }
            .font(.custom("Helvetica", size: 36))
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
        // MARK: REAL BODY
        List(Array(playlist.tracks.enumerated()), id: \.offset) { idx, track in
            ItemView(track: track, idx: idx, isAlbum: playlist is Twib_Music.Album)
        }
        .onAppear() {
            let url = playlist is Twib_Music.Album ? playlist.tracks_url : playlist.tracks_url + "?limit=50"
            if playlist.tracks.isEmpty {
                SpotifyAPI.fetchTracks(playlist, url: url)
            }
        }
    }
}

