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
            ImageView(image_url: playlist.image_url, size: 64)
            VStack(alignment: .leading) {
                Text(playlist.name)
                    .font(.custom("Helvetica Neue", size: 16))
                    .fontWeight(.medium)
                    .lineLimit(2)
                    .padding(.bottom, 4)
                if let album = playlist as? Album {
                    Text(album.artist)
                        .font(.custom("Helvetica Neue", size: 12))
                        .fontWeight(.light)
                        .lineLimit(1)
                }
            }
            .padding(.leading, 12)
            Spacer()
        }
    }
}
