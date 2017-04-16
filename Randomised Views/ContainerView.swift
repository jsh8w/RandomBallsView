//
//  ContainerView.swift
//  Randomised Views
//
//  Created by James Shaw on 13/04/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

class ContainerView: UIView {
    var words:[String] = []
    var wordViewFrames:[CGRect] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.commonInit()
    }
    
    func commonInit() {

    }
    
    func resetAndDrawWords() {
        for subview in self.subviews {
            if let wordView = subview as? WordView {
                wordView.removeFromSuperview()
            }
        }
        
        self.drawWords()
    }
    
    func drawWords() {
        
        // Construct frames of WordViews and increase to maximum possible size
        self.wordViewFrames = []
        while self.wordViewFrames.count == 0 {
            self.wordViewFrames = self.constructWordViewFrames(with: self.words.count)
        }
        self.maxmimiseFrameSizes(maximumWidth: 150.0)
        self.moveAndMaximiseFrameSizes(maximumWidth: 150.0)
        //----------
        
        // Order frames by size
        self.wordViewFrames = self.wordViewFrames.sorted(by: { $0.width > $1.width })
        
        // Order words by size
        self.orderWordStringsByLength()
        
        // Draw WordViews
        for (index, word) in self.words.enumerated() {
            let wordView = WordView(frame: self.wordViewFrames[index], title: word)
            self.addSubview(wordView)
        }
    }
    
    func constructWordViewFrames(with noOfWords: Int) -> [CGRect] {
        var frames: [CGRect] = []
        
        // Get an minimum width/height of the WordView
        let initialDiameter: CGFloat = self.getMinimumDiameter()
        let margin: CGFloat = 5.0
        let availableWidth = self.frame.width - (margin * 2) - initialDiameter
        let availableHeight = self.frame.height - (margin * 2) - initialDiameter
        
        // Find a frame for each word using the minimum width/height
        for _ in 1...noOfWords {
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
    
    // Finds the minimum width/height of the WordView that can be drawn be comparing the area of WordViews and the size of the view
    func getMinimumDiameter() -> CGFloat {
        
        var minimumDiameter: CGFloat = 110.0
        var area = (minimumDiameter * minimumDiameter) * CGFloat(self.words.count)
        let totalArea = (self.bounds.height - 75.0) * (self.bounds.width - 75.0)
        
        while area > totalArea {
            minimumDiameter -= 1.0
            area = (minimumDiameter * minimumDiameter) * CGFloat(self.words.count)
        }
        
        return minimumDiameter
    }
    
    // Increase the size of the each WordView until they intersect another WordView or the bounds of the view
    func maxmimiseFrameSizes(maximumWidth: CGFloat) {
        
        var placedWords:[CGRect] = []
        
        while placedWords.count != self.wordViewFrames.count {
            
            for oldFrame in self.wordViewFrames {
                let newFrame = self.createNewFrame(oldFrame: oldFrame, increaseInSize: 2.0)
                
                // New frame is unavailable
                if self.isFrameAvailable(oldFrame: oldFrame, newFrame: newFrame, existingFrames: self.wordViewFrames) == false || newFrame.width > maximumWidth {
                    if !placedWords.contains(oldFrame) {
                        placedWords.append(oldFrame)
                    }
                }
                else {
                    if let index = self.wordViewFrames.index(of: oldFrame) {
                        self.wordViewFrames[index] = newFrame
                    }
                }
            }
        }
    }
    
    // Attempt to move frames around and increase size of the view
    func moveAndMaximiseFrameSizes(maximumWidth: CGFloat) {
        
        var movedAndPlacedWords:[CGRect] = []
        while movedAndPlacedWords.count != self.wordViewFrames.count {
            
            for oldFrame in self.wordViewFrames {
                
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
                    while self.isFrameAvailable(oldFrame: oldFrame, newFrame: newFrame, existingFrames: self.wordViewFrames) == true && newFrame.width < maximumWidth {
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
                if let index = self.wordViewFrames.index(of: oldFrame) {
                    if !movedAndPlacedWords.contains(oldFrame) {
                        movedAndPlacedWords.append(newFrame)
                        self.wordViewFrames[index] = newFrame
                    }
                }
            }
        }
    }
    
    // Get a random direction and return x, y values to move and remaining directions to try
    func getDirectionWith(directions: [Int], change: CGFloat) -> (CGFloat, CGFloat, [Int]) {
        
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
    func createNewFrame(oldFrame: CGRect, increaseInSize: CGFloat) -> CGRect {
        let newX = oldFrame.origin.x - (increaseInSize / 2)
        let newY = oldFrame.origin.y - (increaseInSize / 2)
        let newDiameter = oldFrame.width + increaseInSize
        let newFrame = CGRect(x: newX, y: newY, width: newDiameter, height: newDiameter)
        
        return newFrame
    }
    
    // Checks if a frame is within the bounds of the view, and that the frame doesn't intersect with any other frames already drawn
    func isFrameAvailable(oldFrame: CGRect?, newFrame: CGRect, existingFrames: [CGRect]) -> Bool {
        
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
    func circleFramesIntersect(frame1: CGRect, frame2: CGRect) -> Bool {
        
        let radiusSum = (frame1.width / 2) + (frame2.width / 2)
        let distanceBetweenCenters = hypotf(Float(frame1.midX - frame2.midX), Float(frame1.midY - frame2.midY))
        
        if CGFloat(distanceBetweenCenters) < radiusSum {
            return true
        }
        
        return false
    }
    
    // Orders the word strings by length
    func orderWordStringsByLength() {
        var orderedWordsArray:[String] = []
        var tempArray = self.words
        
        while tempArray.count != 0 {
            var biggestWord = tempArray.first!
            
            for word in tempArray {
                let biggestWidth = biggestWord.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 14.0))
                let width = word.widthOfString(usingFont: UIFont.boldSystemFont(ofSize: 14.0))
                
                if width > biggestWidth {
                    biggestWord = word
                }
            }
            
            orderedWordsArray.append(biggestWord)
            
            let biggestIndex = tempArray.index(of: biggestWord)!
            tempArray.remove(at: biggestIndex)
        }
        
        self.words = orderedWordsArray
    }
}

extension String {
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        let size = (self as NSString).size(attributes: fontAttributes)
        return size.width
    }
    
    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSFontAttributeName: font]
        let size = self.size(attributes: fontAttributes)
        return size.height
    }
}
