//
//  ViewController.swift
//  JHTempoControlDemo
//
//  Created by Joshua Herkness on 12/24/16.
//  Copyright © 2016 JRH. All rights reserved.
//

import UIKit

class ViewController: UIViewController, JHTempoControlDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        let tempoControl: JHTempoControl = JHTempoControl(frame: CGRect(x: 0, y: 100, width: self.view.frame.size.width, height: 50))
        tempoControl.tintColor = UIColor.red
        tempoControl.delegate = self
        tempoControl.minimumValue = 40
        tempoControl.maximumValue = 300
        
        self.view.addSubview(tempoControl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - JHTempoControlDelegate
    
    func tempoControl(_ JHTempoControl: JHTempoControl, tagForValue value: Int) -> String? {
        let tempoMarkings: [String: ClosedRange] = [
            "grave": 40...49,
            "largo": 50...54,
            "larghetto": 55...59,
            "adagio": 60...69,
            "andante": 70...84,
            "moderato": 85...99,
            "allegretto": 100...114,
            "allegro": 115...139,
            "vivace": 140...149,
            "presto": 150...169,
            "prestissimo": 170...300
        ]
        for (k, v) in tempoMarkings {
            if v.contains(value) { return k.capitalized }
        }
        return nil
    }
    
    func tempoControl(_ JHTempoControl: JHTempoControl, valueMultiplierAfterInterval interval: Double) -> Double? {
        return interval < 3 ? 1 : 10
    }
}

