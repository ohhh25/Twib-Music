//
//  HeadingView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/8/24.
//

import SwiftUI

struct HeadingView: View {
    var body: some View {
        VStack(alignment: .center) {
            // MARK: Standard Views
            HStack {
                Image("cropped")
                    .resizable()
                    .frame(width: 48, height: 48)
                Text("Welcome to Twib Music!")
                    .font(.custom("Helvetica", size: 24))
                    .fontWeight(.bold)
            }
            .padding(.top, 6)
        }
    }
}

#Preview {
    HeadingView()
}
