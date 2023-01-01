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
    var lastUpdate = Double.zero
    var angleRange: ClosedRange<Double> = .pi / 36 ... .pi / 2
    var soundPlayer = SoundPlayer()
    
    func update(at time: Double) {
        let delta = min(time - lastUpdate, 1 / 30)
        lastUpdate = time
        
        updateOldParticles(delta: delta)
    }
    
    func loadEffect(in size: CGSize) {
        particles = []
        soundPlayer.play()
        Task.detached {
            try await Task.sleep(for: .milliseconds(200))
            for _ in 0..<60 {
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
    
    private func updateOldParticles(delta: Double) {
        let oldN = particles.count
        var newN = oldN
        var index = 0
        
        while index < newN {
            if particles[index].update(delta: delta) {
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
    
    @MainActor private func createNewParticle(in size: CGSize, emitting: Bool) {
        let particle: Particle
        if emitting {
            let xCenter = size.width / 2
            let point = CGPoint(x: CGFloat.random(in: xCenter - 50...xCenter + 50),
                                y: CGFloat.random(in: -50 ... -30))
            let direction: Direction = point.x < size.width / 2 ? .left : .right
            particle = make(at: point, direction: direction)
        } else {
            particle = make(at: CGPoint(x: CGFloat.random(in: 0...size.width),
                                        y: CGFloat.random(in: -50 ... -30)))
        }
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
        
        particle.emittingDuration = 0.03
        particle.g = Double.random(in: 200...300)
        if let direction {
            let ang = direction == .left ? .pi - Double.random(in: angleRange) : Double.random(in: angleRange)
            particle.velocity.height = Double.random(in: 200...600)
            particle.velocity.width = particle.velocity.height / tan(ang)
            
            particle.emittingForce = Double.random(in: 3000...5000) * direction.factor
            particle.k = 5
        } else {
            particle.velocity.height = Double.random(in: 100...500)
        }
        
//        let totalDistance = lastSize.height - point.y
//        let vt = sqrt(2 * particle.acceleration.height * totalDistance + pow(Double(particle.velocity.height), 2))
//        particle.lifetime = (vt - particle.velocity.height) / particle.acceleration.height
        
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

