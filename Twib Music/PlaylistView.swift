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
    let a = Playlist(name: "Test", description: "Test", tracks_url: "", image_url: "https://daylist.spotifycdn.com/playlist-covers-mix/en/afternoon_default.jpg", visible: 0)
    PlaylistView(playlist: a)
}
