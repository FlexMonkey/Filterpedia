//
//  ViewController.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import UIKit

class ViewController: UIViewController
{

    let filterNavigator = FilterNavigator()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        view.addSubview(filterNavigator)
    }

    override func viewDidLayoutSubviews()
    {
        filterNavigator.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: 300,
            height: view.frame.height - topLayoutGuide.length).insetBy(dx: 5, dy: 5)
    }


}

