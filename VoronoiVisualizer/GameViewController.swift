//
//  GameViewController.swift
//  VoronoiVisualizer
//
//  Created by Fredrik Sjöberg on 15/02/16.
//  Copyright (c) 2016 FredrikSjoberg. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit
import Descartes

class GameViewController: UIViewController {
    
    @IBOutlet var skView: SKView!
    
    var random: GKRandom!
    var scene: SKScene!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scene = SKScene(size: skView.bounds.size)
        
        skView.showsFPS = true
        skView.showsNodeCount = true
        
        skView.presentScene(scene)
        
        /*
        if let scene = GameScene(fileNamed:"GameScene") {
            // Configure the view.
            let skView = self.view as! SKView
            
            /* Sprite Kit applies additional optimizations to improve rendering performance */
            skView.ignoresSiblingOrder = true
            
            /* Set the scale mode to scale to fit the window */
            scene.scaleMode = .AspectFill
            
            skView.presentScene(scene)
        }*/
    }
    
    override func viewWillAppear(animated: Bool) {
        let source = GKMersenneTwisterRandomSource(seed: 4)
        random = GKRandomDistribution(randomSource: source, lowestValue: 1, highestValue: 100)
        
        let sideSize = 200
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
                scene.addChild(node)
                
                let vertex0 = SKShapeNode(circleOfRadius: 2)
                vertex0.position = $0.p0
                vertex0.fillColor = UIColor.redColor()
                let vertex1 = SKShapeNode(circleOfRadius: 2)
                vertex1.position = $0.p1
                vertex1.fillColor = UIColor.redColor()
                print("--")
                print($0.p0)
                print($0.p1)
                scene.addChild(vertex0)
                scene.addChild(vertex1)
            }
            
            randomPoints.forEach{
                let node = SKShapeNode(circleOfRadius: 2)
                node.position = $0
                node.fillColor = UIColor.greenColor()
                scene.addChild(node)
            }
        }
        catch {
            print(error)
        }
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
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
