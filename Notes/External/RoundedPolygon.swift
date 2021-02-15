//
//  RoundedPolygon.swift
//  Notes
//
//  Created by Ilya Kulinkovich on 2/13/21.
//

import SwiftUI

private func point(from angle: CGFloat, radius: CGFloat, offset: CGPoint) -> CGPoint {
    return CGPoint(x: radius * cos(angle) + offset.x, y: radius * sin(angle) + offset.y)
}

public struct RoundedPolygon: Shape {
    public let sides: Int
    public let cornerRadius: CGFloat

    public init(sides: Int, cornerRadius: CGFloat) {
        self.sides = sides
        self.cornerRadius = cornerRadius
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()

        let center = CGPoint(x: rect.width / 2.0, y: rect.height / 2.0)
        var angle: CGFloat = -.pi / 2
        let angleIncrement = .pi * 2 / CGFloat(sides)
        let length = min(rect.width, rect.height)
        let radius = length / 2.0 - cornerRadius * .pi / 180.0

        var points: [CGPoint] = [point(from: angle, radius: radius, offset: center)]
        for _ in 1...sides - 1 {
            angle += angleIncrement
            points.append(point(from: angle, radius: radius, offset: center))
        }
        
        var cornerRadius = self.cornerRadius

        if cornerRadius < .zero {
            cornerRadius = .zero
        } else {
            let maxCornerRadius = points[0].distance(to: points[1]) / 2.0
            if cornerRadius > maxCornerRadius {
                cornerRadius = maxCornerRadius
            }
        }

        let len = points.count
        path.addArcPoint(previous: points[len - 1], current: points[0 % len], next: points[1 % len], cornerRadius: cornerRadius, isFirst: true)
        for i in 0..<len {
            path.addArcPoint(previous: points[i], current: points[(i + 1) % len], next: points[(i + 2) % len], cornerRadius: cornerRadius, isFirst: false)
        }
        path.closeSubpath()

        return path
    }
}

fileprivate extension Path {
    mutating func addArcPoint(previous: CGPoint, current: CGPoint, next: CGPoint, cornerRadius: CGFloat, isFirst: Bool) {
        var c2p = CGPoint(x: previous.x - current.x, y: previous.y - current.y) // current & previous
        var c2n = CGPoint(x: next.x - current.x, y: next.y - current.y) // current & next
        let distanceP = c2p.distance(to: .zero)
        let distanceN = c2p.distance(to: .zero)

        c2p.x /= distanceP
        c2p.y /= distanceP
        c2n.x /= distanceN
        c2n.y /= distanceN

        let ω = acos(c2n.x * c2p.x + c2n.y * c2p.y)
        let θ = (.pi / 2) - (ω / 2)

        let radius = cornerRadius / θ * (.pi / 4)
        let rTanθ = radius * tan(θ)

        if isFirst {
            let end = CGPoint(x: current.x + rTanθ * c2n.x, y: current.y + rTanθ * c2n.y)
            move(to: end)
        } else {
            let start = CGPoint(x: current.x + rTanθ * c2p.x, y: current.y + rTanθ * c2p.y)
            addLine(to: start)

            let center = CGPoint(x: start.x + c2p.y * radius, y: start.y - c2p.x * radius)
            let startAngle = Angle(radians: Double(atan2(c2p.x, -c2p.y)))
            let endAngle = Angle(radians: startAngle.radians + (2 * Double(θ)))
            addArc(center: center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        }
    }
}

fileprivate extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return hypot(self.x - point.x, self.y - point.y)
    }
}
