//
//  SkyScene.swift
//  StarsOnSky
//
//  Created by Max Subbotin on 1/7/20.
//

import Foundation
import SpriteKit
import GameplayKit

class MeridianNode: SKShapeNode {
    public var rightAscension: CGFloat // radians
    private var _fromPoint: CGPoint
    public var fromPoint: CGPoint {
        get {
            return _fromPoint
        }
        set {
            _fromPoint = newValue
            self.path = self.path(from: _fromPoint, to: _toPoint)
        }
    }
    private var _toPoint: CGPoint
    public var toPoint: CGPoint {
        get {
            return _toPoint
        }
        set {
            _toPoint = newValue
            self.path = self.path(from: _fromPoint, to: _toPoint)
        }
    }
    
    init(from p1: CGPoint, to p2: CGPoint, ra: CGFloat) {
        _fromPoint = p1
        _toPoint = p2
        rightAscension = ra
        
        super.init()
        
        self.path = self.path(from: _fromPoint, to: _toPoint)
    }
    
    required init?(coder aDecoder: NSCoder) {
        _fromPoint = .zero
        _toPoint = .zero
        rightAscension = 0
        super.init(coder: aDecoder)
    }
    
    private func path(from p1: CGPoint, to p2: CGPoint) -> CGMutablePath {
        let path = CGMutablePath()
        path.move(to: p1)
        path.addLine(to: p2)
        return path
    }
}

class CircleNode: SKShapeNode {
    private var _radius: CGFloat
    public var radius: CGFloat {
        get {
            return _radius
        }
        set {
            _radius = newValue
            self.path = self.path(forRadius: _radius)
        }
    }
    override var position: CGPoint {
        get {
            return super.position
        }
        set {
            super.position = newValue
            self.path = self.path(forRadius: _radius)
        }
    }
    
    init(radius: CGFloat, position: CGPoint) {
        _radius = radius
        
        super.init()
        
        self.path = self.path(forRadius: self.radius)
        super.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        _radius = 0
        super.init(coder: aDecoder)
    }
    
    private func path(forRadius r: CGFloat) -> CGMutablePath {
        let path: CGMutablePath = CGMutablePath()
        path.addArc(center: CGPoint.zero, radius: r, startAngle: 0.0, endAngle: CGFloat(2.0) * CGFloat.pi, clockwise: false)
        return path
    }
}

class ParallelNode: CircleNode {
    public var declination: CGFloat // from 0.0 till 1.0
    
    init(radius: CGFloat, position: CGPoint, declination: CGFloat) {
        self.declination = declination
        
        super.init(radius: radius, position: position)
        
        self.path = self.path(forRadius: self.radius)
        self.position = position
    }
    
    required init?(coder aDecoder: NSCoder) {
        declination = 0
        super.init(coder: aDecoder)
    }
    
    private func path(forRadius r: CGFloat) -> CGMutablePath {
        let path: CGMutablePath = CGMutablePath()
        path.addArc(center: CGPoint.zero, radius: r, startAngle: 0.0, endAngle: CGFloat(2.0) * CGFloat.pi, clockwise: false)
        return path
    }
}

class StarNode: CircleNode {
    public var rightAscension: CGFloat
    public var declination: CGFloat
    
    init(withRightAscention ra: CGFloat, declination dec: CGFloat, radius r: CGFloat, position pos: CGPoint) {
        self.rightAscension = ra
        self.declination = dec
        
        super.init(radius: r, position: pos)
    }
    
    required init?(coder aDecoder: NSCoder) {
        rightAscension = 0
        declination = 0
        super.init(coder: aDecoder)
    }
}

enum SkyHemishpere {
    case north
    case south
}

class SkyScene: SKScene {
    private var skyCircle = SKShapeNode(circleOfRadius: 100)
    private var skyRadius = CGFloat(0)
    private var skyCenter = CGPoint.zero
    private var catalog = Catalog()
    
    private var meridianNodes = [SKShapeNode]()
    private var parallelNodes = [SKShapeNode]()
    
    private var prevZoom = CGFloat(1)
    private var prevCameraPoint = CGPoint.zero
    
    private var minZoom = CGFloat(1)
    private var maxZoom = CGFloat(8)
    
    private var _hemisphere: SkyHemishpere = .north
    public var hemisphere: SkyHemishpere {
        get {
            return _hemisphere
        }
        set {
            _hemisphere = newValue
            renderStars()
        }
    }
    
    private var _thresholdMagnitude: Double = 4.0
    public var thresholdMagnitude: Double {
        get {
            return _thresholdMagnitude
        }
        set {
            _thresholdMagnitude = newValue
            renderStars()
        }
    }

    override func sceneDidLoad() {
        super.sceneDidLoad()
        self.backgroundColor = ColorSchema.current.backgroundColor
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        renderSky()
        
        renderStars()
        
        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(pinchGesture(_:)))
        view.addGestureRecognizer(pinchGesture)
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(panGesture(_:)))
        panGesture.maximumNumberOfTouches = 1
        view.addGestureRecognizer(panGesture)
        
        let cameraNode = SKCameraNode()
        cameraNode.position = skyCenter
        self.addChild(cameraNode)
        self.camera = cameraNode
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
            
            let line = MeridianNode(from: skyCenter, to: CGPoint(x: x, y: y), ra: angle)
            line.strokeColor = ColorSchema.current.skyLineColor
            line.lineWidth = 1.0
            line.alpha = 0.5
            addChild(line)
            
            meridianNodes.append(line)
        }
    }
    
    func drawParallels() {
        let step = 0.33333 // 30 degrees
        let n = Int(1 / step)
        
        for i in 0...n {
            let decl = CGFloat(1.0 - Double(i) * step)
            let radius = skyRadius * decl
            
            let circle = ParallelNode(radius: radius, position: skyCenter, declination: decl)
            circle.strokeColor = ColorSchema.current.skyLineColor
            circle.alpha = 0.5
            circle.lineWidth = 1.0
            addChild(circle)
            
            parallelNodes.append(circle)
        }
    }
    
    func renderStars() {
        for s in self.children {
            if s is StarNode {
                s.removeFromParent()
            }
        }
        
        //let stars = hemisphere == .north ? catalog.stars.filter({ $0.dec != nil && $0.rarad != nil && $0.dec! >= 0.0 }) :
        //    catalog.stars.filter({ $0.dec != nil && $0.rarad != nil && $0.dec! <= 0.0 })
        
        let stars = catalog.getStars(brighterThan: thresholdMagnitude, inHemispere: hemisphere)
        
        for star in stars {
            let radius = skyRadius * CGFloat(1.0 - abs(star.dec! / 90))
            let x = skyCenter.x + radius * CGFloat(cos(star.rarad!))
            let y = skyCenter.y + radius * CGFloat(sin(star.rarad!))
            
            let maxStarSize = CGFloat(6)
            let k = CGFloat(1.0 - star.mag! * 0.125)
            
            let starSize = max(1, maxStarSize * k) / 2
            let starCircle = StarNode(withRightAscention: CGFloat(star.rarad!),
                                      declination: CGFloat(star.decrad!),
                                      radius: CGFloat(starSize),
                                      position: CGPoint(x: x, y: y))
            
            let lvl = min(1.0, 1.0 * k)
            
            starCircle.fillColor = .white
            starCircle.alpha = lvl
            
            if star.mag! <= 1 {
                starCircle.glowWidth = CGFloat(starSize)
            }
            addChild(starCircle)
        }
    }
    
    @objc func pinchGesture(_ gesture: UIPinchGestureRecognizer) {
        if let camera = self.camera {

            let locationInView = gesture.location(in: self.view)
            let loc = self.convertPoint(fromView: locationInView)
            
            let scale = prevZoom * gesture.scale
            //camera.setScale()
            
            //skyCircle.setScale(scale)
            
            if gesture.state == .ended {
                prevZoom = scale
            }
            
            //skyCircle.run(SKAction.resize(toWidth: skyRadius * scale, duration: 0))
            //skyCircle.run(SKAction.resize(toHeight: skyRadius * scale, duration: 0))
            
            skyCircle.run(SKAction.scale(to: scale, duration: 0))
            
            //prevZoom = scale
            
            //let x = locationInView.x - skyRadius * scale
            
            /*let locationAfterScale = self.convertPoint(fromView: locationInView)
            let delta = CGPoint(x: loc.x - locationAfterScale.x, y: loc.y - locationAfterScale.y)
            let newPoint = CGPoint(x: camera.position.x + delta.x, y: camera.position.y + delta.y)*/
            //camera.position = CGPoint(x: locationInView.x * scale, y: locationInView.y * scale)
            
            
            
            for node in children.filter({ $0 is ParallelNode }) {
                let parallel = node as! ParallelNode
                parallel.radius = skyRadius * CGFloat(scale) * parallel.declination
            }
            
            for node in children.filter({ $0 is MeridianNode }) {
                let meridian = node as! MeridianNode
                let x = skyCenter.x + skyRadius * CGFloat(scale) * cos(meridian.rightAscension)
                let y = skyCenter.y + skyRadius * CGFloat(scale) * sin(meridian.rightAscension)
                meridian.toPoint = CGPoint(x: x, y: y)
            }
            
            for node in children.filter({ $0 is StarNode }) {
                let star = node as! StarNode
                let radius = skyRadius * CGFloat(scale) * CGFloat(1.0 - abs(star.declination * 2 / CGFloat.pi))
                let x = skyCenter.x + radius * CGFloat(cos(star.rightAscension))
                let y = skyCenter.y + radius * CGFloat(sin(star.rightAscension))
                star.position = CGPoint(x: x, y: y)
            }
        }
    }
    
    @objc func panGesture(_ gesture: UIPanGestureRecognizer) {
        if gesture.numberOfTouches > 1 {
            return
        }
        
        if let camera = self.camera {
            if gesture.state == .began {
                prevCameraPoint = camera.position
            }
            
            let translation = gesture.translation(in: self.view)
            let pos = CGPoint(x: prevCameraPoint.x - translation.x, y: prevCameraPoint.y + translation.y)
            camera.position = pos
        }
    }
}
