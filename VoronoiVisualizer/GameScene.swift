//
//  GameScene.swift
//  VoronoiVisualizer
//
//  Created by Fredrik Sjöberg on 15/02/16.
//  Copyright (c) 2016 FredrikSjoberg. All rights reserved.
//

import SpriteKit
import GameplayKit
import Descartes

class GameScene: SKScene {
    var random: GKRandom!
    
    var siteNodes: SKNode!
    var edgeNodes: SKNode!
    var boundsNodes: SKShapeNode!
    var needsEdgeUpdate: Bool = false
    
    var bounds: BoundaryType!
    
    override func didMoveToView(view: SKView) {
        let source = GKMersenneTwisterRandomSource(seed: 4)
        random = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: 100)
        
        siteNodes = SKNode()
        edgeNodes = SKNode()
        
        let bVerts = [CGPoint(x: 30, y: 30), CGPoint(x: 180, y: 40), CGPoint(x: 170, y: 150), CGPoint(x: 100, y: 180), CGPoint(x: 40, y: 160)]
        let polygon = ConvexPolygon(vertices: bVerts)
        bounds = polygon
        
        boundsNodes = SKShapeNode()
        let path = CGPathCreateMutable()
        polygon.edges.forEach{
            CGPathMoveToPoint(path, nil, $0.p0.x, $0.p0.y)
            CGPathAddLineToPoint(path, nil, $0.p1.x, $0.p1.y)
        }
        boundsNodes.strokeColor = UIColor.yellowColor()
        boundsNodes.path = path
        
//        bounds = CGRect(x: 0, y: 0, width: sideSize, height: sideSize)
        
        
        
        addChild(siteNodes)
        addChild(edgeNodes)
        addChild(boundsNodes)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            if bounds.contains(location) {
                let existing = siteNodes.nodeAtPoint(location)
                if existing != siteNodes {
                    // Remove old node
                    existing.removeFromParent()
                    
                }
                else {
                    let node = SKShapeNode(circleOfRadius: 2)
                    node.position = location
                    node.fillColor = UIColor.greenColor()
                    siteNodes.addChild(node)
                }
                needsEdgeUpdate = true
            }
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if needsEdgeUpdate {
            edgeNodes.removeAllChildren()
            
            
            let points = siteNodes.children.map{ $0.position }

            let voronoi = Voronoi(points: points, boundary: bounds)
            
            let edges = voronoi.voronoiEdges
            edges.forEach{
                let node = SKShapeNode()
                let path = CGPathCreateMutable()
                CGPathMoveToPoint(path, nil, $0.p0.x, $0.p0.y)
                CGPathAddLineToPoint(path, nil, $0.p1.x, $0.p1.y)
                node.path = path
                edgeNodes.addChild(node)
                
                let vertex0 = SKShapeNode(circleOfRadius: 2)
                vertex0.position = $0.p0
                vertex0.fillColor = UIColor.redColor()
                let vertex1 = SKShapeNode(circleOfRadius: 2)
                vertex1.position = $0.p1
                vertex1.fillColor = UIColor.redColor()
                edgeNodes.addChild(vertex0)
                edgeNodes.addChild(vertex1)
            }
            
            needsEdgeUpdate = false
        }
    }
    
    let sideSize = 200
    
    func resetPoints() {
        siteNodes.removeAllChildren()
        edgeNodes.removeAllChildren()
    }
}
