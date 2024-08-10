//
//  AlbumView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/9/24.
//

import SwiftUI

struct AlbumView: View {
    var album: Album
    
    var body: some View {
        PlaylistView(playlist: album)
    }
}
