//
//  ViewController.swift
//  Randomised Views
//
//  Created by James Shaw on 13/04/2017.
//  Copyright © 2017 James Shaw. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var randomCirclesView: RandomCirclesView!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let noOfCircles = Int(arc4random_uniform(15)) + 1
        self.randomCirclesView.resetAndDrawCircles(count: noOfCircles, maxSize: 150.0)
    }
    
    @IBAction func reloadButtonPressed(sender: UIButton) {
        let noOfCircles = Int(arc4random_uniform(15)) + 1
        self.randomCirclesView.resetAndDrawCircles(count: noOfCircles, maxSize: 150.0)
    }
}

