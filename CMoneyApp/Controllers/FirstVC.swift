//
//  ViewController.swift
//  CMoneyApp
//
//  Created by Penny Huang on 2020/5/18.
//  Copyright © 2020 Penny Huang. All rights reserved.
//

import UIKit

class FirstVC: UIViewController {
    

    @IBOutlet weak var enterButtonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        enterButtonOutlet.layer.cornerRadius = enterButtonOutlet.frame.height / 2
        
        let colour1 = #colorLiteral(red: 0.3803921569, green: 0.2901960784, blue: 0.8274509804, alpha: 1).cgColor
        let colour2 = #colorLiteral(red: 0.924761951, green: 0.2762447596, blue: 0.4667485952, alpha: 1).cgColor
        let gradient = CAGradientLayer()
        gradient.frame = view.frame
        gradient.colors = [colour1,colour2]
        gradient.locations = [0, 1]

        view.layer.insertSublayer(gradient, at: 0)
    }


}

