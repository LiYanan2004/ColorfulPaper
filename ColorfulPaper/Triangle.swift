//
//  Traiangle.swift
//  ColorfulPaper
//
//  Created by LiYanan2004 on 2023/1/3.
//

import SwiftUI

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            path.move(to: CGPoint(x: rect.midX, y: rect.minY))
            path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.closeSubpath()
        }
    }
}

struct Triangle_Preview: PreviewProvider {
    static var previews: some View {
        Triangle()
    }
}
