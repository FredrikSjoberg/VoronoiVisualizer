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
    
    var subdivisionNodes: SKNode!
    var boundsFrame: CGRect!
    var minScale: Int = 20
    func updateMinScale(scale: Float) {
        let val = Int(scale*20)+10
        minScale = val
        
        let points = siteNodes.children.map{ $0.position }
        let voronoi = Voronoi(points: points, boundary: bounds)
        let edges = voronoi.voronoiEdges
        updateGrid(edges)
    }
    
    private var selectMode: SelectMode = .Site
    
    enum SelectMode {
        case Site
        case Cell
    }
    
    var bounds: BoundaryType!
    
    let siteRadius: CGFloat = 10
    override func didMoveToView(view: SKView) {
        let source = GKMersenneTwisterRandomSource(seed: 4)
        random = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: 100)
        
        
        siteNodes = SKNode()
        edgeNodes = SKNode()
        highlightNodes = SKNode()
        subdivisionNodes = SKNode()
        
        
        
        setupBoundsRect(view)
        
        setupTouches()
        
        addChild(subdivisionNodes)
        addChild(siteNodes)
        addChild(edgeNodes)
        addChild(boundsNodes)
        addChild(highlightNodes)
    }
    
    func setupBoundsRect(view: SKView) {
        let polygon = ConvexPolygon(rect: view.frame)
        bounds = polygon
        boundsNodes = SKShapeNode()
        let path = CGPathCreateMutable()
        polygon.edges.forEach{
            CGPathMoveToPoint(path, nil, $0.p0.x, $0.p0.y)
            CGPathAddLineToPoint(path, nil, $0.p1.x, $0.p1.y)
        }
        boundsNodes.strokeColor = UIColor.redColor()
        boundsNodes.path = path
        
        boundsFrame = view.frame
    }
    
    func setupBoundsPolygon() {
        let bVerts = [CGPoint(x: 30, y: 30),
                      CGPoint(x: frame.origin.x+frame.size.width-20, y: 40),
                      CGPoint(x: frame.origin.x+frame.size.width-30, y: frame.origin.y+frame.size.height-70),
                      CGPoint(x: (frame.origin.x+frame.size.width)/2, y: frame.origin.y+frame.size.height-40),
                      CGPoint(x: 40, y: frame.origin.y+frame.size.height-30)]
        let polygon = ConvexPolygon(vertices: bVerts)
        bounds = polygon
        
        boundsNodes = SKShapeNode()
        let path = CGPathCreateMutable()
        polygon.edges.forEach{
            CGPathMoveToPoint(path, nil, $0.p0.x, $0.p0.y)
            CGPathAddLineToPoint(path, nil, $0.p1.x, $0.p1.y)
        }
        boundsNodes.strokeColor = UIColor.redColor()
        boundsNodes.path = path
    }
    
    private func setupTouches() {
        
        let node = SKShapeNode(circleOfRadius: siteRadius)
        node.position = CGPoint(x: 60, y: 60)
        node.fillColor = UIColor.greenColor()
        siteNodes.addChild(node)
        
        let node1 = SKShapeNode(circleOfRadius: siteRadius)
        node1.position = CGPoint(x: frame.origin.x+frame.size.width-70, y: frame.origin.y+frame.size.height-270)
        node1.fillColor = UIColor.greenColor()
        siteNodes.addChild(node1)
        
        let node2 = SKShapeNode(circleOfRadius: siteRadius)
        node2.position = CGPoint(x: (frame.origin.x+frame.size.width)/2, y: 50)
        node2.fillColor = UIColor.greenColor()
        siteNodes.addChild(node2)
        
        let node3 = SKShapeNode(circleOfRadius: siteRadius)
        node3.position = CGPoint(x: 80, y: frame.origin.y+frame.size.height-250)
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
            let node = SKShapeNode(circleOfRadius: siteRadius)
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
                
                
                /*
                let maxRect = cell.maximumInscribedRect
                if maxRect.0 != CGRectZero {
                    let rectnode = SKShapeNode()
                    let rectpath = CGPathCreateMutable()
                    maxRect.0.borders.forEach{
                        CGPathMoveToPoint(rectpath, nil, $0.p0.x, $0.p0.y)
                        CGPathAddLineToPoint(rectpath, nil, $0.p1.x, $0.p1.y)
                        rectnode.path = rectpath
                    }
                    rectnode.strokeColor = UIColor.redColor()
                    highlightNodes.addChild(rectnode)
                }*/
            }
            
        }
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
       updateScene()
    }
    
    private func updateScene() {
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
                
                let vertex0 = SKShapeNode(circleOfRadius: 3)
                vertex0.position = $0.p0
                vertex0.fillColor = UIColor.redColor()
                let vertex1 = SKShapeNode(circleOfRadius: 3)
                vertex1.position = $0.p1
                vertex1.fillColor = UIColor.redColor()
                edgeNodes.addChild(vertex0)
                edgeNodes.addChild(vertex1)
            }
            
            updateGrid(edges)
            
            needsEdgeUpdate = false
        }
    }
    
    private func updateGrid(edges: [Line]) {
        subdivisionNodes.removeAllChildren()
        
        let depth = CGFloat(minScale)
        let splitGrid = boundsFrame.splitIntersect(edges, minSize: boundsFrame.size/depth, increaseDepth: true)
        splitGrid.forEach{ rect in
            let node = SKShapeNode(rect: rect)
            
            node.strokeColor = UIColor.cyanColor()
            
            subdivisionNodes.addChild(node)
            
            let intersects = edges.map{ rect.intersects($0) != nil }.reduce(false) {
                (sum, next) in
                return sum || next
            }
            
            if intersects {
                node.fillColor = UIColor.brownColor()
            }
        }
    }
    
    func resetPoints() {
        siteNodes.removeAllChildren()
        edgeNodes.removeAllChildren()
        highlightNodes.removeAllChildren()
        subdivisionNodes.removeAllChildren()
    }
    
    func setSelectMode(mode: SelectMode) {
        self.selectMode = mode
    }
}


extension ConvexPolygon {
    var boundingBox: CGRect {
        guard edges.count > 0 else { return CGRectZero }
        
        let xsort = edges.sort{ $0.p0.x < $1.p0.x }
        let ysort = edges.sort{ $0.p0.y < $1.p0.y }
        let xmin = xsort.first!.p0.x
        let ymin = ysort.first!.p0.y
        let xmax = xsort.last!.p0.x
        let ymax = ysort.last!.p0.y
        
        return CGRect(x: xmin, y: ymin, width: xmax-xmin, height: ymax-ymin)
    }

}



