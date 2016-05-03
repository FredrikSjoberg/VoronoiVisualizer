//
//  GridProducer.swift
//  VoronoiVisualizer
//
//  Created by Fredrik Sjöberg on 03/05/16.
//  Copyright © 2016 FredrikSjoberg. All rights reserved.
//

import UIKit

func / (lhs: CGSize, scalar: CGFloat) -> CGSize {
    return CGSize(width: lhs.width/scalar, height: lhs.height/scalar)
}

func > (lhs: CGSize, rhs: CGSize) -> Bool {
    return lhs.height > rhs.height && lhs.width > rhs.width
}

struct Grid {
    let array: [[CGRect]]
    let count: Int
    
    init(bounds: CGRect, count: Int) {
        self.count = count
        let sub = bounds.size / CGFloat(count)
        array = (0..<count).map{ row in
            return (0..<count).map{
                CGRect(origin: CGPoint(x: CGFloat($0)*sub.width, y: CGFloat(row)*sub.height), size: sub)
            }
            
        }
    }
}

import Descartes
class SplitGrid {
    var array: [CGRect]
    let minSize: CGSize
    
    init(rect: CGRect, depth: Int) {
        array = [rect]
        minSize = rect.size / CGFloat(depth)
    }
    
    func subdivide(lines: [Line], finalDivide: Bool) {
        array = array.flatMap{ $0.recursiveSubdivide(lines, minSize: self.minSize, increaseDepth: finalDivide) }
    }
}

extension CGRect {
    func recursiveSubdivide(lines: [Line], minSize: CGSize, increaseDepth: Bool) -> [CGRect] {
        if intersects(lines) {
            let q = quarternize()
            if quarterSize > minSize {
                return q.flatMap{ $0.recursiveSubdivide(lines, minSize: minSize, increaseDepth: increaseDepth) }
            }
            else if increaseDepth {
                return q
            }
        }
        return [self]
    }
    
    func intersects(lines: [Line]) -> Bool {
        return lines.map{ intersects($0) != nil }.reduce(false) {
            (sum, next) in
            return sum || next
        }
    }
    
    var quarterSize: CGSize {
        return size/2
    }
    
    func quarternize() -> [CGRect] {
        let halfSize = quarterSize
        return [
            CGRect(origin: origin, size: halfSize),
            CGRect(origin: CGPoint(x: origin.x, y: origin.y+halfSize.height), size: halfSize),
            CGRect(origin: CGPoint(x: origin.x+halfSize.width, y: origin.y+halfSize.height), size: halfSize),
            CGRect(origin: CGPoint(x: origin.x+halfSize.width, y: origin.y), size: halfSize)
        ]
    }
    
    func subdivide(minSize: CGSize) -> [CGRect] {
        let newSize = quarterSize
        if newSize.height > minSize.height && newSize.width > minSize.width {
            return quarternize()
        }
        return [self]
    }
}