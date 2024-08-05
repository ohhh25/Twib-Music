//
//  TrackView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/5/24.
//

import SwiftUI

struct TrackView: View {
    @State var playlist: Playlist
    
    var body: some View {
        List(playlist.tracks) { track in
            Text(track.name)
        }
    }
}
