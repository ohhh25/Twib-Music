//
//  TrackView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import SwiftUI

struct TrackView: View {
    @StateObject var playlist: Playlist
    
    var body: some View {
        HStack(alignment: .top) {
            
            VStack(alignment: .leading) {
                Text(playlist.name)
                    .font(.custom("Helvetica", size: 16))
                    .fontWeight(.medium)
                    .padding(.top, 2)
                Spacer()
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
        .frame(height: 144)
        .padding(.bottom, 6)
        List(playlist.tracks) {track in
            HStack {
                AsyncImage(url: URL(string: track.image_url)) { image in
                    image
                        .resizable()
                } placeholder: {
                    ProgressView()
                }
                    .frame(width: 48, height: 48)
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
            }
        }
        .onAppear() {
            let url = playlist.tracks_url + "?limit=50"
            if playlist.tracks.isEmpty {
                SpotifyAPI.fetchTracks(playlist, url: url)
            }
        }
    }
}
