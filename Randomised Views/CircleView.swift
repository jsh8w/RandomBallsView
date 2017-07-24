//
//  WordView.swift
//  Randomised Views
//
//  Created by James Shaw on 13/04/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

class CircleView: UIView {
    let colors = [UIColor.green, UIColor.red, UIColor.blue, UIColor.orange, UIColor.brown]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let color = self.randomColor()
        self.drawCircle(with: color)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func drawCircle(with color: UIColor) {
        let layer = CAShapeLayer()
        layer.path = UIBezierPath(ovalIn: CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: self.frame.height)).cgPath
        layer.fillColor = color.cgColor
        self.layer.addSublayer(layer)
    }
    
    func randomColor() -> UIColor {
        let randomIndex = Int(arc4random_uniform(UInt32(self.colors.count - 1)))
        return self.colors[randomIndex]
    }
}
