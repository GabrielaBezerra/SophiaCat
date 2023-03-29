//
//  ContentView.swift
//  CollectCows
//
//  Created by Gabriela Bezerra on 28/03/23.
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    var body: some View {
        GeometryReader { proxy in
            SpriteView(scene: GameScene(size: proxy.size))
                .ignoresSafeArea()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .previewInterfaceOrientation(.landscapeLeft)
    }
}
