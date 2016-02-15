//
//  GKRandom+Extensions.swift
//  VoronoiVisualizer
//
//  Created by Fredrik Sjöberg on 15/02/16.
//  Copyright © 2016 FredrikSjoberg. All rights reserved.
//

import Foundation
import GameplayKit
import CoreGraphics

extension GKRandom {
    func nextUniform(interval: ClosedInterval<Float>) -> Float {
        return (interval.start + (interval.end - interval.start))*self.nextUniform()
    }
}