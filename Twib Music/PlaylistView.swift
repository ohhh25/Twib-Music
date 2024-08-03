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

#Preview {
    let a = Playlist(name: "Liked Songs", description: "", tracks_url: "https://api.spotify.com/v1/me/tracks", image_url: "https://raw.githubusercontent.com/ohhh25/Twib-Music/befa16c9a8b5798ef26763197cdb5fe072b70bbc/Twib%20Music/Assets.xcassets/saved.imageset/saved.png", visible: -1)
    PlaylistView(playlist: a)
}
