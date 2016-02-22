//
//  CGPoint+Extensions.swift
//  VoronoiVisualizer
//
//  Created by Fredrik Sjöberg on 15/02/16.
//  Copyright © 2016 FredrikSjoberg. All rights reserved.
//

import Foundation
import GameplayKit
import CoreGraphics

extension CGPoint {
    init(random: GKRandom, interval: ClosedInterval<Float>) {
        x = CGFloat(random.nextUniform(interval))
        y = CGFloat(random.nextUniform(interval))
    }
    
    
    func centeroid(points: Set<CGPoint>) -> CGPoint {
        return points.reduce(self){ $0 + $1 }/Float(points.count + 1)
    }
}

internal func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
    return CGPoint(x: lhs.x+rhs.x, y: lhs.y+rhs.y)
}

func / (point: CGPoint, value: Float) -> CGPoint {
    return CGPoint(x: point.x*CGFloat(value), y: point.y*CGFloat(value))
}