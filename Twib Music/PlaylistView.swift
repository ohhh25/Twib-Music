//
//  PlaylistView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/1/24.
//

import SwiftUI

struct PlaylistView: View {
    var playlist: Playlist
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: playlist.image_url)) { image in
                image
                    .resizable()
            } placeholder: {
                ProgressView()
            }
                .frame(width: 64, height: 64)
            Text(playlist.name)
                .font(.custom("Helvetica", size: 16))
                .padding(.leading, 12)
            Spacer()
        }
    }
}

struct TrackView: View {
    @State var playlist: Playlist
    
    var body: some View {
        List(playlist.tracks) { track in
            Text(track.name)
        }
        .onAppear {
            let tracks = Interfacer.fetchTracks(base_url: playlist.tracks_url)
            DispatchQueue.main.async {
                playlist.tracks = tracks
            }
        }
    }
}


#Preview {
    let a = Playlist(name: "Liked Songs", description: "", tracks_url: "https://api.spotify.com/v1/me/tracks", image_url: "https://raw.githubusercontent.com/ohhh25/Twib-Music/befa16c9a8b5798ef26763197cdb5fe072b70bbc/Twib%20Music/Assets.xcassets/saved.imageset/saved.png", visible: -1)
    PlaylistView(playlist: a)
}
