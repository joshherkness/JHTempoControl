//
//  ViewController.swift
//  JHTempoControlDemo
//
//  Created by Joshua Herkness on 12/24/16.
//  Copyright © 2016 JRH. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tempoControl: JHTempoControl = JHTempoControl(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 50))
        
        self.view.addSubview(tempoControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

