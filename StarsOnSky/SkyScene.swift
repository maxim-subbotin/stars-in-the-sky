//
//  SkyScene.swift
//  StarsOnSky
//
//  Created by Max Subbotin on 1/7/20.
//

import Foundation
import SpriteKit
import GameplayKit

class SkyScene: SKScene {
    private var skyCircle = SKShapeNode(circleOfRadius: 100)
    private var skyRadius = CGFloat(0)
    private var skyCenter = CGPoint.zero
    private var catalog = Catalog()

    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.backgroundColor = ColorSchema.current.backgroundColor
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        renderSky()

        catalog.load()
        
        renderStars()
    }
    
    func renderSky() {
        skyRadius = min(frame.width, frame.height) / 2 - 10
        skyCenter = CGPoint(x: frame.midX, y: frame.midY)
        
        skyCircle = SKShapeNode(circleOfRadius: skyRadius)
        skyCircle.position = skyCenter
        skyCircle.strokeColor = ColorSchema.current.skyBorderColor
        skyCircle.fillColor = ColorSchema.current.skyColor
        skyCircle.glowWidth = 1
        
        self.addChild(skyCircle)
        
        drawMeridians()
        drawParallels()
    }
    
    func drawMeridians() {
        let step = CGFloat(0.523599) // 30 degrees
        let n = Int(CGFloat.pi * 2 / step) + 1
        for i in 0...n {
            let angle = CGFloat(i) * step
            let x = skyCenter.x + skyRadius * cos(angle)
            let y = skyCenter.y + skyRadius * sin(angle)
            
            let line = SKShapeNode()
            let path = CGMutablePath()
            path.move(to: skyCenter)
            path.addLine(to: CGPoint(x: x, y: y))
            line.path = path
            line.strokeColor = ColorSchema.current.skyLineColor
            line.alpha = 0.5
            addChild(line)
        }
    }
    
    func drawParallels() {
        let step = 0.33333 // 30 degrees
        let n = Int(1 / step)
        
        for i in 0...n {
            let radius = skyRadius * CGFloat(1.0 - Double(i) * step)
            
            let circle = SKShapeNode(circleOfRadius: radius)
            circle.position = skyCenter
            circle.strokeColor = ColorSchema.current.skyLineColor
            circle.alpha = 0.5
            addChild(circle)
        }
    }
    
    func renderStars() {
        for star in catalog.stars {
            if star.dec == nil || star.rarad == nil {
                continue
            }
            
            if star.dec! < 0 {
                continue
            }
            
            let radius = skyRadius * CGFloat(1.0 - abs(star.dec! / 90))
            let x = skyCenter.x + radius * CGFloat(cos(star.rarad!))
            let y = skyCenter.y + radius * CGFloat(sin(star.rarad!))
            
            let starSize = (6 - star.mag!) / 2
            let starCircle = SKShapeNode(circleOfRadius: CGFloat(starSize))
            starCircle.position = CGPoint(x: x, y: y)
            starCircle.fillColor = .white
            
            if star.mag! <= 1 {
                starCircle.glowWidth = CGFloat(starSize)
            }
            addChild(starCircle)
        }
    }
}
