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

let gradientImage = CIFilter(
    name: "CIRadialGradient",
    parameters: [
        kCIInputCenterKey:
            CIVector(x: 320, y: 320),
        "inputRadius0": 200,
        "inputRadius1": 400,
        "inputColor0":
            CIColor(red: 0, green: 0, blue: 0),
        "inputColor1":
            CIColor(red: 1, green: 1, blue: 1)
    ])?
    .outputImage?
    .cropped(to: CGRect(x: 0, y: 0, width: 640, height: 640))

let assets = [
    NamedImage(name: "Mona Lisa", ciImage: CIImage(image: UIImage(named: "monalisa.jpg")!)!),
    NamedImage(name: "Stop", ciImage: CIImage(image: UIImage(named: "stop.jpg")!)!),
    NamedImage(name: "Sunflower", ciImage: CIImage(image: UIImage(named: "sunflower.jpg")!)!),
    NamedImage(name: "Vegas", ciImage: CIImage(image: UIImage(named: "vegas.jpg")!)!),
    NamedImage(name: "Sunset", ciImage: CIImage(image: UIImage(named: "sunset.jpg")!)!),
    NamedImage(name: "Coffee", ciImage: CIImage(image: UIImage(named: "coffeecup.jpg")!)!),
    NamedImage(name: "Mascot", ciImage: CIImage(image: UIImage(named: "carMascot.jpg")!)!),
    NamedImage(name: "Gradient", ciImage: gradientImage!)
]

let assetLabels = assets.map({ $0.name })
