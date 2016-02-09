//
//  FilterNavigator.swift
//  Filterpedia
//
//  Created by Simon Gladman on 29/12/2015.
//  Copyright © 2015 Simon Gladman. All rights reserved.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.

//  You should have received a copy of the GNU General Public License
//  along with this program.  If not, see <http://www.gnu.org/licenses/>

import Foundation
import UIKit

class FilterNavigator: UIView
{
    let filterCategories =
    [
        CategoryCustomFilters,
        kCICategoryBlur,
        kCICategoryColorAdjustment,
        kCICategoryColorEffect,
        kCICategoryCompositeOperation,
        kCICategoryDistortionEffect,
        kCICategoryGenerator,
        kCICategoryGeometryAdjustment,
        kCICategoryGradient,
        kCICategoryHalftoneEffect,
        kCICategoryReduction,
        kCICategorySharpen,
        kCICategoryStylize,
        kCICategoryTileEffect,
        kCICategoryTransition,
    ].sort{ CIFilter.localizedNameForCategory($0) < CIFilter.localizedNameForCategory($1)}
    
    /// Filterpedia doesn't support code generators, color cube filters, filters that require NSValue
    let exclusions = ["CIQRCodeGenerator",
        "CIPDF417BarcodeGenerator",
        "CICode128BarcodeGenerator",
        "CIAztecCodeGenerator",
        "CIColorCubeWithColorSpace",
        "CIColorCube",
        "CIAffineTransform",
        "CIAffineClamp",
        "CIAffineTile",
        "CICrop"] // to do: fix CICrop!
    
    let segmentedControl = UISegmentedControl(items: [FilterNavigatorMode.Grouped.rawValue, FilterNavigatorMode.Flat.rawValue])
    
    let tableView: UITableView =
    {
        let tableView = UITableView(frame: CGRectZero,
            style: UITableViewStyle.Plain)
        
        tableView.registerClass(UITableViewHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: "HeaderRenderer")
        
        tableView.registerClass(UITableViewCell.self,
            forCellReuseIdentifier: "ItemRenderer")
   
        return tableView
    }()
    
    var mode: FilterNavigatorMode = .Grouped
    {
        didSet
        {
            tableView.reloadData()
        }
    }
    
    weak var delegate: FilterNavigatorDelegate?
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        
        CustomFiltersVendor.registerFilters()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.addTarget(self,
            action: "segmentedControlChange",
            forControlEvents: UIControlEvents.ValueChanged)
        
        addSubview(tableView)
        addSubview(segmentedControl)
    }

    required init?(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }

    func segmentedControlChange()
    {
        mode = segmentedControl.selectedSegmentIndex == 0 ? .Grouped : .Flat
    }
    
    override func layoutSubviews()
    {
        let segmentedControlHeight = segmentedControl.intrinsicContentSize().height
        
        tableView.frame = CGRect(x: 0,
            y: 0,
            width: frame.width,
            height: frame.height - segmentedControlHeight)
        
        segmentedControl.frame = CGRect(x: 0,
            y: frame.height - segmentedControlHeight,
            width: frame.width,
            height: segmentedControlHeight)
    }
}


// MARK: UITableViewDelegate extension

extension FilterNavigator: UITableViewDelegate
{
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
    {
        let filterName: String
        
        switch mode
        {
        case .Grouped:
            filterName = supportedFilterNamesInCategory(filterCategories[indexPath.section]).sort()[indexPath.row]
        case .Flat:
            filterName = supportedFilterNamesInCategories(nil).sort()[indexPath.row]
        }
        
        delegate?.filterNavigator(self, didSelectFilterName: filterName)
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch mode
        {
        case .Grouped:
            return 40
        case .Flat:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let cell = tableView.dequeueReusableHeaderFooterViewWithIdentifier("HeaderRenderer")! as UITableViewHeaderFooterView

        switch mode
        {
        case .Grouped:
            cell.textLabel?.text = CIFilter.localizedNameForCategory(filterCategories[section])
        case .Flat:
            cell.textLabel?.text = nil
        }
        
        return cell
    }
    
    func supportedFilterNamesInCategory(category: String?) -> [String]
    {
        return CIFilter.filterNamesInCategory(category).filter
        {
            !exclusions.contains($0)
        }
    }
    
    func supportedFilterNamesInCategories(categories: [String]?) -> [String]
    {
        return CIFilter.filterNamesInCategories(categories).filter
        {
            !exclusions.contains($0)
        }
    }
}

// MARK: UITableViewDataSource extension

extension FilterNavigator: UITableViewDataSource
{
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        switch mode
        {
        case .Grouped:
            return filterCategories.count
        case .Flat:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch mode
        {
        case .Grouped:
            return supportedFilterNamesInCategory(filterCategories[section]).count
        case .Flat:
            return supportedFilterNamesInCategories(nil).count
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCellWithIdentifier("ItemRenderer",
            forIndexPath: indexPath) 

        let filterName: String
        
        switch mode
        {
        case .Grouped:
            filterName = supportedFilterNamesInCategory(filterCategories[indexPath.section]).sort()[indexPath.row]
        case .Flat:
            filterName = supportedFilterNamesInCategories(nil).sort
            {
                CIFilter.localizedNameForFilterName($0) ?? $0 < CIFilter.localizedNameForFilterName($1) ?? $1
            }[indexPath.row]
        }
        
        cell.textLabel?.text = CIFilter.localizedNameForFilterName(filterName) ?? (CIFilter(name: filterName)?.attributes[kCIAttributeFilterDisplayName] as? String) ?? filterName
        
        return cell
    }
}

// MARK: Filter Navigator Modes

enum FilterNavigatorMode: String
{
    case Grouped
    case Flat
}

// MARK: FilterNavigatorDelegate

protocol FilterNavigatorDelegate: class
{
    func filterNavigator(filterNavigator: FilterNavigator, didSelectFilterName: String)
}

