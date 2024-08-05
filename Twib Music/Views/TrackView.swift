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
        List(playlist.tracks) { track in
            Text(track.name)
        }
        .onAppear() {
            SpotifyAPI.fetchTracks(playlist)
        }
    }
}
