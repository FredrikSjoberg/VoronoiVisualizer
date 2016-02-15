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
//    var points: [CGPoint] = []
    var random: GKRandom!
    
    var siteNodes: SKNode!
    var needsReset: Bool = false
    var edgeNodes: SKNode!
    var needsEdgeUpdate: Bool = false
    
    override func didMoveToView(view: SKView) {
        let source = GKMersenneTwisterRandomSource(seed: 4)
        random = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: 100)
        
        siteNodes = SKNode()
        edgeNodes = SKNode()
        
        addChild(siteNodes)
        addChild(edgeNodes)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            
            let existing = siteNodes.nodeAtPoint(location)
            if existing != siteNodes {
                // Remove old node
                existing.removeFromParent()
                
            }
            else {
//                points.append(location)
                
                let node = SKShapeNode(circleOfRadius: 2)
                node.position = location
                node.fillColor = UIColor.greenColor()
                siteNodes.addChild(node)
            }
            needsEdgeUpdate = true
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if needsEdgeUpdate {
            edgeNodes.removeAllChildren()
            
            // Improve the random points
            let bounds = CGRect(x: 0, y: 0, width: sideSize, height: sideSize)
            
            let points = siteNodes.children.map{ $0.position }
            
            do {
                let voronoi = try Voronoi(points: points, bounds: bounds)
                
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
            }
            catch {
                print(error)
            }
            
            needsEdgeUpdate = false
        }
    }
    
    let sideSize = 200
    /*func defaultVoronoi() {
        let numPoints = 30
        
        // Generate random points
        let interval = ClosedInterval(Standard.pointIndentation, Float(sideSize)-Standard.pointIndentation)
        let randomPoints = (0..<numPoints).map{ _ in return CGPoint(random: random, interval: interval) }
        
        // Improve the random points
        let bounds = CGRect(x: 0, y: 0, width: sideSize, height: sideSize)
        
        do {
            let voronoi = try Voronoi(points: randomPoints, bounds: bounds)
            
            let edges = voronoi.voronoiEdges
            edges.forEach{
                let node = SKShapeNode()
                let path = CGPathCreateMutable()
                CGPathMoveToPoint(path, nil, $0.p0.x, $0.p0.y)
                CGPathAddLineToPoint(path, nil, $0.p1.x, $0.p1.y)
                node.path = path
                addChild(node)
                
                let vertex0 = SKShapeNode(circleOfRadius: 2)
                vertex0.position = $0.p0
                vertex0.fillColor = UIColor.redColor()
                let vertex1 = SKShapeNode(circleOfRadius: 2)
                vertex1.position = $0.p1
                vertex1.fillColor = UIColor.redColor()
                print("--")
                print($0.p0)
                print($0.p1)
                addChild(vertex0)
                addChild(vertex1)
            }
            
            randomPoints.forEach{
                let node = SKShapeNode(circleOfRadius: 2)
                node.position = $0
                node.fillColor = UIColor.greenColor()
                addChild(node)
            }
        }
        catch {
            print(error)
        }
    }*/
    
    func resetPoints() {
//        points.removeAll()
        siteNodes.removeAllChildren()
        edgeNodes.removeAllChildren()
        
    }
    
    struct Standard {
        static let numPoints: Float = 500 // TODO: Should probably be moved
        static let pointIndentation: Float = 10
        
        static func numPoints(mapSize: Int) -> UInt {
            let standardArea = 2048 * 2048
            let standardPointsPerArea = Standard.numPoints / Float(standardArea)
            
            let area = Float(mapSize * mapSize)
            return UInt(area * standardPointsPerArea)
        }
    }
}
