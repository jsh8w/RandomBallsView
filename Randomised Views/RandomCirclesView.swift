//
//  ContainerView.swift
//  Randomised Views
//
//  Created by James Shaw on 13/04/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

class RandomCirclesView: UIView {
    var circleViewFrames:[CGRect] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    func commonInit() { }
    
    func resetAndDrawCircles(count: Int, maxSize: CGFloat) {
        for subview in self.subviews {
            if let circleView = subview as? CircleView {
                circleView.removeFromSuperview()
            }
        }
        self.circleViewFrames = []
        
        self.drawCircles(count: count, maxSize: maxSize)
    }
    
    private func drawCircles(count: Int, maxSize: CGFloat) {
        
        // Construct frames of circles and increase to maximum possible size
        while self.circleViewFrames.count == 0 {
            self.circleViewFrames = self.constructCircleViewFrames(count: count, maxSize: maxSize)
        }
        self.maxmimiseFrameSizes(maximumWidth: maxSize)
        self.moveAndMaximiseFrameSizes(maximumWidth: maxSize)
        //----------

        // Draw circles
        for frame in self.circleViewFrames {
            let circleView = CircleView(frame: frame)
            self.addSubview(circleView)
        }
    }
    
    private func constructCircleViewFrames(count: Int, maxSize: CGFloat) -> [CGRect] {
        var frames: [CGRect] = []
        
        // Get an minimum width/height of the WordView
        let initialDiameter: CGFloat = self.getMinimumDiameter(count: count, maxSize: maxSize)
        let margin: CGFloat = 5.0
        let availableWidth = self.frame.width - (margin * 2) - initialDiameter
        let availableHeight = self.frame.height - (margin * 2) - initialDiameter
        
        // Find a frame for each word using the minimum width/height
        for _ in 1...count {
            var randomX = CGFloat(arc4random_uniform(UInt32(availableWidth))) + CGFloat(margin)
            var randomY = CGFloat(arc4random_uniform(UInt32(availableHeight))) + CGFloat(margin)
            var newFrame = CGRect(x: randomX, y: randomY, width: initialDiameter, height: initialDiameter)
            
            var count = 0
            while self.isFrameAvailable(oldFrame: nil, newFrame: newFrame, existingFrames: frames) == false {
                randomX = CGFloat(arc4random_uniform(UInt32(availableWidth))) + CGFloat(margin)
                randomY = CGFloat(arc4random_uniform(UInt32(availableHeight))) + CGFloat(margin)
                newFrame = CGRect(x: randomX, y: randomY, width: initialDiameter, height: initialDiameter)
                
                count += 1

                // Break out of the method and try drawing again if 100 attempts have been made for this frame
                if count > 100 {
                    return []
                }
            }
            
            frames.append(newFrame)
        }
        
        return frames
    }
    
    // Find the minimum frame of the circle that can be drawn be comparing the area of all circles and the size of the view
    private func getMinimumDiameter(count: Int, maxSize: CGFloat) -> CGFloat {
        
        var minimumDiameter: CGFloat = maxSize
        var area = (minimumDiameter * minimumDiameter) * CGFloat(count)
        let totalArea = (self.bounds.height - 100.0) * (self.bounds.width - 100.0)
        
        while area > totalArea {
            minimumDiameter -= 1.0
            area = (minimumDiameter * minimumDiameter) * CGFloat(count)
        }
        
        return minimumDiameter
    }
    
    // Increase the size of the each circle until they intersect with another circle or the bounds of the view
    private func maxmimiseFrameSizes(maximumWidth: CGFloat) {
        
        var placedCircles:[CGRect] = []
        
        while placedCircles.count != self.circleViewFrames.count {
            
            for oldFrame in self.circleViewFrames {
                let newFrame = self.createNewFrame(oldFrame: oldFrame, increaseInSize: 2.0)

                if self.isFrameAvailable(oldFrame: oldFrame, newFrame: newFrame, existingFrames: self.circleViewFrames) == false || newFrame.width > maximumWidth {

                    if !placedCircles.contains(oldFrame) {
                        placedCircles.append(oldFrame)
                    }
                }
                else {
                    if let index = self.circleViewFrames.index(of: oldFrame) {
                        self.circleViewFrames[index] = newFrame
                    }
                }
            }
        }
    }
    
    // Attempt to move frames around and increase size of the circle
    private func moveAndMaximiseFrameSizes(maximumWidth: CGFloat) {
        
        var movedAndPlacedCircles:[CGRect] = []
        while movedAndPlacedCircles.count != self.circleViewFrames.count {
            
            for oldFrame in self.circleViewFrames {
                
                // 1 = Up and Left, 2 = Up and Right, 3 = Down and Left, 4 = Down and Right
                var directions:[Int] = [1, 2, 3, 4]
                var newFrame = oldFrame
                var tempFrame = oldFrame
                
                // Try each direction
                while directions.count != 0 {
                    
                    let change: CGFloat = 2.0
                    
                    // Get a direction to move
                    let (x, y, remainingDirections) = self.getDirectionWith(directions: directions, change: change)
                    directions = remainingDirections
                    
                    // Calculate new frame with the direction
                    newFrame = CGRect(x: newFrame.origin.x + x, y: newFrame.origin.y + y, width: newFrame.width + change, height: newFrame.height + change)
                    
                    // Keep moving/increasing in the same direction until frame is unavailable
                    var frameChanged = false
                    while self.isFrameAvailable(oldFrame: oldFrame, newFrame: newFrame, existingFrames: self.circleViewFrames) == true && newFrame.width < maximumWidth {
                        tempFrame = newFrame
                        newFrame = CGRect(x: newFrame.origin.x + x, y: newFrame.origin.y + y, width: newFrame.width + change, height: newFrame.height + change)
                        
                        frameChanged = true
                    }
                    newFrame = tempFrame
                    //------------
                    
                    // if frame has not changed, revert frame back to old frame
                    if frameChanged == false {
                        newFrame = oldFrame
                    }
                }
                
                // Once all directions have been tried, update frame in global array
                if let index = self.circleViewFrames.index(of: oldFrame) {
                    if !movedAndPlacedCircles.contains(oldFrame) {
                        movedAndPlacedCircles.append(newFrame)
                        self.circleViewFrames[index] = newFrame
                    }
                }
            }
        }
    }
    
    // Get a random direction and return x, y values to move and remaining directions to try
    private func getDirectionWith(directions: [Int], change: CGFloat) -> (CGFloat, CGFloat, [Int]) {
        
        var remainingDirections = directions
        let randomIndex = Int(arc4random_uniform(UInt32(directions.count - 1)))
        let direction = directions[randomIndex]
        
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        
        // Taking into consideration that width and height will increase in down and right directions
        switch direction {
        case 1:
            // Up and Left
            x = -change
            y = -change
            
        case 2:
            // Up and Right
            x = 0.0
            y = -change

        case 3:
            // Down and Left
            x = -change
            y = 0.0
            
        case 4:
            // Down and Right
            x = 0.0
            y = 0.0
        default:
            x = -change
            y = -change
        }
        
        remainingDirections.remove(at: randomIndex)
        return (x, y, remainingDirections)
    }
    
    // Incrase the same of a frame
    private func createNewFrame(oldFrame: CGRect, increaseInSize: CGFloat) -> CGRect {
        let newX = oldFrame.origin.x - (increaseInSize / 2)
        let newY = oldFrame.origin.y - (increaseInSize / 2)
        let newDiameter = oldFrame.width + increaseInSize
        let newFrame = CGRect(x: newX, y: newY, width: newDiameter, height: newDiameter)
        
        return newFrame
    }
    
    // Checks frame is within the bounds of the view, and that the frame doesn't intersect with any other frames already drawn
    private func isFrameAvailable(oldFrame: CGRect?, newFrame: CGRect, existingFrames: [CGRect]) -> Bool {
        
        let viewBounds = CGRect(x: 5.0, y: 5.0, width: self.bounds.width - 10.0, height: self.bounds.height - 10.0)
        
        for existingFrame in existingFrames {
            if let oldFrame = oldFrame {
                // Make sure the old frame is not the existing frame we're currently inspecting
                if existingFrame != oldFrame {
                    if self.circleFramesIntersect(frame1: existingFrame, frame2: newFrame) || !viewBounds.contains(newFrame) {
                        return false
                    }
                }
                else {
                    if !viewBounds.contains(newFrame) {
                        return false
                    }
                }
            }
            else {
                if self.circleFramesIntersect(frame1: existingFrame, frame2: newFrame) || !viewBounds.contains(newFrame) {
                    return false
                }
            }
        }
        
        return true
    }
    
    // Determines if the circles within two frames intersect
    private func circleFramesIntersect(frame1: CGRect, frame2: CGRect) -> Bool {
        
        let radiusSum = (frame1.width / 2) + (frame2.width / 2)
        let distanceBetweenCenters = hypotf(Float(frame1.midX - frame2.midX), Float(frame1.midY - frame2.midY))
        
        if CGFloat(distanceBetweenCenters) < radiusSum {
            return true
        }
        
        return false
    }
}
