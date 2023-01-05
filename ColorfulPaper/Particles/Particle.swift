//
//  Particle.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/1.
//

import SwiftUI

struct Particle {
    
    // MARK: Frame and Shape
    var size: CGSize = CGSize(width: 12, height: 24)
    var position: CGPoint = .zero
    var frame: CGRect { CGRect(origin: position, size: size) }
    var shape: AnyShape = AnyShape(Circle())
    
    // MARK: 3D transformation
    var degrees: Double = 0.0
    var (x, y, z): (Double, Double, Double) = (0.0, 0.0, 0.0)
    var transform: CATransform3D {
        CATransform3DMakeRotation(Angle(degrees: degrees).radians, x, y, z)
    }
    var rotationSpeed: Double = 0.0

    // MARK: Color
    var color: Color = .gray
    var shading: GraphicsContext.Shading { .color(color) }
    
    // MARK: Speed
    /// The speed of the particle on the x and y axis.
    var velocity: CGSize = CGSize(width: 0, height: 0)
    /// The speed of the particle in total.
    var totalVelocity: Double {
        sqrt(velocity.width * velocity.width + velocity.height * velocity.height)
    }
    /// The angle of the velocity and the ceiling.
    var velocityAngle: Angle {
        if velocity.width == 0 {
            return .degrees(90)
        } else {
            var radians = atan(velocity.height / velocity.width)
            if radians < 0 {
                radians += Double.pi
            }
            return Angle(radians: radians)
        }
    }
    /// The gravity acceleration of the particle world.
    /// This value will not be the real-world's 9.8 (m/s^2).
    /// The unit should be pixels, not metres.
    var g: Double = 9.8
    /// The mass of the particle.
    var m: Double = 1.0
    /// Resistance coefficient.
    var k: Double = 0.01
    /// The acceleration on both x and y axis.
    /// Computed based on `g`, `m`, `k`, `totalVelocity` and `velocityAngle`
    var acceleration: CGSize {
        /// ignore resistance in y-axis.
        /// Strictly (in y-axis): `g - (k * totalVelocity) * sin(velocityAngle.radians) / m`
        CGSize(width: (-k * totalVelocity) * cos(velocityAngle.radians) / m,
               height: g)
    }
    
    // MARK: Update particle for next frame
    mutating func update(delta: Double) {
        var velocity = velocity
        position.x += velocity.width * delta
        position.y += velocity.height * delta
        let acceleration = acceleration
        velocity.width += acceleration.width * delta
        velocity.height += acceleration.height * delta
        self.velocity = velocity
        degrees += rotationSpeed * delta
    }
}
