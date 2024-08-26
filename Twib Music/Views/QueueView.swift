//
//  QueueView.swift
//  Twib Music
//
//  Created by Lukas Cao on 8/26/24.
//

import SwiftUI

fileprivate let topColor = Color(red:(118.0 / 255.0), green:(214.0 / 255.0), blue:(255.0 / 255.0))
fileprivate let botColor = Color(red:(255.0 / 255.0), green:(252.0 / 255.0), blue:(121.0 / 255.0))
fileprivate let grad = [botColor, topColor, botColor]

struct QueueView: View {
    var body: some View {
        VStack {
            Text("Queue is Empty")
                .font(.custom("Helvetica", size: 24))
                .fontWeight(.medium)
                .padding(.top, 12)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AngularGradient(colors: grad, center: UnitPoint(x: 0, y: 0)))
    }
}

#Preview {
    QueueView()
}
