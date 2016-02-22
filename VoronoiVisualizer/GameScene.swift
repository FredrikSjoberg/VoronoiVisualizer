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
    var highlightNodes: SKNode!
    var needsEdgeUpdate: Bool = false
    
    private var selectMode: SelectMode = .Site
    
    enum SelectMode {
        case Site
        case Cell
    }
    
    var bounds: BoundaryType!
    
    override func didMoveToView(view: SKView) {
        let source = GKMersenneTwisterRandomSource(seed: 4)
        random = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: 100)
        
        siteNodes = SKNode()
        edgeNodes = SKNode()
        highlightNodes = SKNode()
        
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
        
        setupTouches()
        
        addChild(siteNodes)
        addChild(edgeNodes)
        addChild(boundsNodes)
        addChild(highlightNodes)
    }
    
    private func setupTouches() {
        
        let node = SKShapeNode(circleOfRadius: 2)
        node.position = CGPoint(x: 60, y: 60)
        node.fillColor = UIColor.greenColor()
        siteNodes.addChild(node)
        
        let node1 = SKShapeNode(circleOfRadius: 2)
        node1.position = CGPoint(x: 130, y: 130)
        node1.fillColor = UIColor.greenColor()
        siteNodes.addChild(node1)
        
        let node2 = SKShapeNode(circleOfRadius: 2)
        node2.position = CGPoint(x: 100, y: 50)
        node2.fillColor = UIColor.greenColor()
        siteNodes.addChild(node2)
        
        let node3 = SKShapeNode(circleOfRadius: 2)
        node3.position = CGPoint(x: 80, y: 150)
        node3.fillColor = UIColor.greenColor()
        siteNodes.addChild(node3)
        
        needsEdgeUpdate = true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
        
        for touch in touches {
            let location = touch.locationInNode(self)
            if bounds.contains(location) {
                
                switch selectMode {
                case .Site: selectSite(location)
                case .Cell: selectCell(location)
                }
            }
        }
    }
    
    private func selectSite(location: CGPoint) {
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
    
    private func selectCell(location: CGPoint) {
        let existing = siteNodes.nodeAtPoint(location)
        if existing != siteNodes {
            // Highlight cell around site
            highlightNodes.removeAllChildren()
            let sitepos = existing.position
            
            let points = siteNodes.children.map{ $0.position }
            let voronoi = Voronoi(points: points, boundary: bounds)
            if let cell = voronoi.cellAt(sitepos) {
                let node = SKShapeNode()
                let path = CGPathCreateMutable()
                cell.edges.forEach{
                    CGPathMoveToPoint(path, nil, $0.p0.x, $0.p0.y)
                    CGPathAddLineToPoint(path, nil, $0.p1.x, $0.p1.y)
                    node.path = path
                }
                node.strokeColor = UIColor.greenColor()
                highlightNodes.addChild(node)
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        if needsEdgeUpdate {
            edgeNodes.removeAllChildren()
            highlightNodes.removeAllChildren()
            
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
        highlightNodes.removeAllChildren()
    }
    
    func setSelectMode(mode: SelectMode) {
        self.selectMode = mode
    }
}
