//
//  Assets.swift
//  Filterpedia
//
//  Created by Simon Gladman on 30/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//

import CoreImage
import UIKit

typealias NamedImage = (name: String, ciImage: CIImage)

let assets = [
    NamedImage(name: "Sunflower", ciImage: CIImage(image: UIImage(named: "sunflower.jpg")!)!),
    NamedImage(name: "Mona Lisa", ciImage: CIImage(image: UIImage(named: "monalisa.jpg")!)!)
]

let assetLabels = assets.map({ $0.name })