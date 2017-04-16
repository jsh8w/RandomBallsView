//
//  ViewController.swift
//  Randomised Views
//
//  Created by James Shaw on 13/04/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var containerView: ContainerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    @IBAction func reloadButtonPressed(sender: UIButton) {
        self.drawContainerViewWords()
    }
    
    func drawContainerViewWords() {
        self.containerView.words = ["Hello", "this", "is", "a very very long string", "and", "these", "are", "test strings", "for the drawing", "logic"]
        self.containerView.resetAndDrawWords()
    }
}

