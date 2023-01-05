//
//  ContentView.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/1.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var model = ParticleModel()
    
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            
            TimelineView(.animation) { timeline in
                let _: () = {
                    let now = timeline.date.timeIntervalSinceReferenceDate
                    model.update(at: now, size: size)
                }()
                
                ZStack {
                    ForEach(model.particles.indices, id: \.self) { index in
                        let particle = model.particles[index]
                        particle.shape
                            .fill(particle.color)
                            .rotation3DEffect(.degrees(particle.degrees), axis: (x: particle.x, y: particle.y, z: particle.z))
                            .frame(width: particle.frame.width, height: particle.frame.height)
                            .position(particle.frame.origin)
                            .tag(index)
                    }
                }
                .frame(width: size.width, height: size.height)
                .drawingGroup()
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onEnded { _ in model.loadEffect(in: size) }
            )
            .task { model.loadEffect(in: size) }
        }
#if os(macOS)
        .background(VisualEffectView())
#endif
        .ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

// Sadly, I cannot fin a way to apply 3D transformation to each particle.
//
//Canvas(rendersAsynchronously: true) { context, size in
//    model.update(at: now, size: size)
//
//    for index in model.particles.indices {
//        let particle = model.particles[index]
//        let innerContext = context
//    }
//}
