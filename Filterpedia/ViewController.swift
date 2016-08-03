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
    let filterDetail = FilterDetail()
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
       
        view.addSubview(filterNavigator)
        view.addSubview(filterDetail)
        
        filterNavigator.delegate = self
    }

    override func viewDidLayoutSubviews()
    {
        filterNavigator.frame = CGRect(x: 0,
            y: topLayoutGuide.length,
            width: 300,
            height: view.frame.height - topLayoutGuide.length).insetBy(dx: 5, dy: 5)
        
        filterDetail.frame = CGRect(x: 300,
            y: topLayoutGuide.length,
            width: view.frame.width - 300,
            height: view.frame.height - topLayoutGuide.length).insetBy(dx: 5, dy: 5)
    }
}

extension ViewController: FilterNavigatorDelegate
{
    func filterNavigator(_ filterNavigator: FilterNavigator, didSelectFilterName: String)
    {
        filterDetail.filterName = didSelectFilterName
    }
}
