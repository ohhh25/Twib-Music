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
        HStack {
            Spacer()
            Text("\(playlist.tracks.count) songs")
                .font(.custom("Helvetica", size: 16))
                .italic()
                .padding(.trailing, 24)
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
                VStack(alignment: .leading) {
                    Text(track.name)
                        .font(.custom("Helvetica", size: 16))
                        .padding(.bottom, 2)
                    Text(track.artist)
                        .font(.custom("Helvetica", size: 12))
                        .fontWeight(.light)
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
