//
//  Particle.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/1.
//

import SwiftUI

struct Particle {
    var time: Double = 0.0
    var lifetime: Double = Double.infinity
    
    // 大小和形状
    var size: CGSize = CGSize(width: 12, height: 24)
    var position: CGPoint = .zero
    var frame: CGRect { CGRect(origin: position, size: size) }
    var shape: AnyShape = AnyShape(Circle())
    
    // 三维旋转
    var degrees: Double = 0.0
    var (x, y, z): (Double, Double, Double) = (0.0, 0.0, 0.0)
    var transform: CATransform3D {
        CATransform3DMakeRotation(Angle(degrees: degrees).radians, x, y, z)
    }
    var rotationSpeed: Double = 0.0

    // 颜色
    var color: Color = .gray
    var shading: GraphicsContext.Shading { .color(color) }
    
    // 速度
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
    var emittingForce: Double = 0.0
    var emittingDuration: Double = 0.0
    /// The acceleration on both x and y axis.
    /// Computed based on `g`, `m`, `k`, `totalVelocity` and `velocityAngle`
    var acceleration: CGSize {
        CGSize(
            width: (-k * totalVelocity + (time > emittingDuration ? 0.0 : emittingForce)) * cos(velocityAngle.radians) / m,
            height: g + (time > emittingDuration ? 0.0 : emittingForce - k * totalVelocity) * sin(velocityAngle.radians) / m
        )
    }
    
    // 更新 Particle
    // 返回当前 Particle 是否还在屏幕内显示
    mutating func update(delta: Double) -> Bool {
        time += delta
        var velocity = velocity
        position.x += velocity.width * delta
        position.y += velocity.height * delta
        let acceleration = acceleration
        velocity.width += acceleration.width * delta
        velocity.height += acceleration.height * delta
//        print("\(self.velocity.width) -> \(velocity.width), acce: \(acceleration.width)")
        self.velocity = velocity
        degrees += rotationSpeed * delta
        
        return lifetime >= time
    }
}
