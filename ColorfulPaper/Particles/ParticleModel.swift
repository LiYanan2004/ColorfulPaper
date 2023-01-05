//
//  ParticleModel.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/1.
//

import SwiftUI

class ParticleModel: ObservableObject {
    enum Direction {
        case left, right
        var factor: Double { self == .left ? -1.0 : 1.0 }
    }
    
    var particles = [Particle]()
    private let soundPlayer = SoundPlayer()
    private var currentTask: Task<Void, Error>?
    private var lastUpdate = Double.zero
    
    func update(at time: Double, size: CGSize) {
        let delta = min(time - lastUpdate, 1 / 30)
        lastUpdate = time
        
        updateOldParticles(delta: delta, size: size)
    }
    
    func loadEffect(in size: CGSize) {
#if os(iOS)
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.prepare()
#endif
        currentTask?.cancel()
        particles = []
        soundPlayer.play()
        currentTask = Task.detached {
#if os(iOS)
            await generator.impactOccurred()
#endif
            try await Task.sleep(for: .milliseconds(100))
            for _ in 0..<Int(size.width / 10) {
                await self.createNewParticle(in: size, emitting: true)
            }
            try await Task.sleep(for: .milliseconds(size.width / 10))
            for _ in 0..<20 {
                await self.createNewParticle(in: size, emitting: false)
            }
            for _ in 0..<15 {
                try await Task.sleep(for: .milliseconds(80))
                for _ in 0..<Int(size.width / 30) {
                    await self.createNewParticle(in: size, emitting: false)
                }
            }
        }
    }
    
    private func updateOldParticles(delta: Double, size: CGSize) {
        let oldN = particles.count
        var newN = oldN
        var index = 0
        
        while index < newN {
            particles[index].update(delta: delta)
            if particleIsVisible(particles[index], in: size) {
                index += 1
            } else {
                newN -= 1
                particles.swapAt(index, newN)
            }
        }
        
        if newN < oldN {
            particles.removeSubrange(newN..<oldN)
        }
    }
    
    private func particleIsVisible(_ particle: Particle, in canvasSize: CGSize) -> Bool {
        let topCenterPoint = CGPoint(
            x: particle.position.x,
            y: particle.position.y - particle.size.height / 2
        )
        guard topCenterPoint.y <= canvasSize.height else { return false }
        guard topCenterPoint.x + particle.size.width / 2 >= 0 else { return false }
        guard topCenterPoint.x - particle.size.width / 2 <= canvasSize.width else { return false }
        
        return true
    }
    
    @MainActor private func createNewParticle(in size: CGSize, emitting: Bool) {
        guard !Task.isCancelled else { return }
        
        var particle: Particle
        if emitting {
            let xCenter = size.width / 2
            let offset = size.width / 5
            let point = CGPoint(x: CGFloat.random(in: xCenter - offset...xCenter + offset),
                                y: CGFloat.random(in: -50 ... -30))
            let direction: Direction = point.x < size.width / 2 ? .left : .right
            particle = make(at: point, direction: direction)
            particle.k = 5.0
        } else {
            particle = make(at: CGPoint(x: CGFloat.random(in: 0...size.width),
                                        y: CGFloat.random(in: -50 ... -30)))
        }
        particles.insert(particle, at: 0)
    }
    
    @MainActor private func createNewParticle(at position: CGPoint) {
        guard !Task.isCancelled else { return }
        
        let particle = make(at: position)
        particles.insert(particle, at: 0)
    }
    
    private func make(at point: CGPoint, direction: Direction? = nil) -> Particle {
        var particle = Particle()
        
        particle.position = point
        let sizeMultiply = Double.random(in: 0.5...1)
        particle.size.width *= sizeMultiply
        particle.size.height *= sizeMultiply
        particle.shape = randomShape()
        particle.color = Color.particleColors.randomElement()!
        
        particle.degrees = Double.random(in: 0...360)
        particle.rotationSpeed = Double.random(in: 300...600) * Double(Int.random(in: 0...1) == 0 ? -1 : 1)
        particle.x = Double.random(in: 0...1)
        particle.y = Double.random(in: 0...1)
        particle.z = Double.random(in: 0...1)
    
        particle.g = Double.random(in: 300...400)
        if let direction {
            let ang = direction == .left ? .pi - Double.random(in: Double.emittingRange) : Double.random(in: Double.emittingRange)
            particle.velocity.height = Double.random(in: 200...600)
            particle.velocity.width = particle.velocity.height / tan(ang)
        } else {
            particle.velocity.height = Double.random(in: 100...500)
        }
    
        return particle
    }
     
    private func randomShape() -> AnyShape {
        let collection: [AnyShape] = [AnyShape(Circle()), AnyShape(Ellipse()), AnyShape(Rectangle()), AnyShape(Triangle())]
        return collection.randomElement()!
    }
}

extension Color {
    static var particleColors: [Color] {
        [.yellow, .green, .blue, .mint, .teal, .cyan, .pink, .red]
    }
}

extension Double {
    static var emittingRange: ClosedRange<Double> = 0 ... .pi / 3
}
