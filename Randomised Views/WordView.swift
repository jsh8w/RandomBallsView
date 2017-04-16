//
//  WordView.swift
//  Randomised Views
//
//  Created by James Shaw on 13/04/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

class WordView: UIView {
    var title: String
    let colors = [UIColor.green, UIColor.red, UIColor.blue, UIColor.orange, UIColor.brown]
    
    init(frame: CGRect, title: String) {
        self.title = title
        super.init(frame: frame)
        
        let color = self.randomColor()
        self.drawCircle(with: color)
        self.drawLabel(with: title)
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
    
    func drawLabel(with title: String) {
        
        let margin: CGFloat = 5.0
        let label = UILabel(frame: CGRect(x: margin, y: margin, width: self.frame.width - (margin * 2), height: self.frame.height - (margin * 2)))
        label.text = title
        label.textAlignment = .center
        label.textColor = UIColor.white
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        self.addSubview(label)
    }
    
    func randomColor() -> UIColor {
        let randomIndex = Int(arc4random_uniform(UInt32(self.colors.count - 1)))
        return self.colors[randomIndex]
    }
}
