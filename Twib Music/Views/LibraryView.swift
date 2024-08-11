//
//  LibraryView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/10/24.
//

import SwiftUI

struct LibraryView: View {
    let playlists: [Playlist]
    
    var body: some View {
        NavigationStack {
            HeadingView()
            Text("Spotify Account Connected!")
                .font(.custom("Helvetica", size: 16))
                .padding(.bottom, 6)
            Divider()
            List(playlists) { playlist in
                NavigationLink {
                    TrackView(playlist: playlist)
                } label: {
                    PlaylistView(playlist: playlist)
                }
            }
        }
        .listStyle(.plain)
    }
}

struct ImageView: View {
    let image_url: String
    let size: CGFloat
    
    var body: some View {
        AsyncImage(url: URL(string: image_url)) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .frame(width: size, height: size)
    }
}
