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
        List(playlist.tracks) { track in
            Text(track.name)
        }
        .onAppear() {
            let url = playlist.tracks_url + "?limit=50"
            if playlist.tracks.isEmpty {
                SpotifyAPI.fetchTracks(playlist, url: url)
            }
        }
    }
}
