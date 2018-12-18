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
    ].sorted{ CIFilter.localizedName(forCategory: $0) < CIFilter.localizedName(forCategory: $1)}
    
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
        let tableView = UITableView(frame: CGRect.zero,
            style: UITableViewStyle.plain)
        
        tableView.register(UITableViewHeaderFooterView.self,
            forHeaderFooterViewReuseIdentifier: "HeaderRenderer")
        
        tableView.register(UITableViewCell.self,
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
            action: #selector(FilterNavigator.segmentedControlChange),
            for: UIControlEvents.valueChanged)
        
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
        let segmentedControlHeight = segmentedControl.intrinsicContentSize.height
        
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
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        let filterName: String
        
        switch mode
        {
        case .Grouped:
            filterName = supportedFilterNamesInCategory(filterCategories[indexPath.section]).sorted()[indexPath.row]
        case .Flat:
            filterName = supportedFilterNamesInCategories(nil).sorted
            {
                CIFilter.localizedName(forFilterName: $0) ?? $0 < CIFilter.localizedName(forFilterName: $1) ?? $1
            }[indexPath.row]
        }
        
        delegate?.filterNavigator(self, didSelectFilterName: filterName)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    {
        switch mode
        {
        case .Grouped:
            return 40
        case .Flat:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: "HeaderRenderer")! as UITableViewHeaderFooterView

        switch mode
        {
        case .Grouped:
            cell.textLabel?.text = CIFilter.localizedName(forCategory: filterCategories[section])
        case .Flat:
            cell.textLabel?.text = nil
        }
        
        return cell
    }
    
    func supportedFilterNamesInCategory(_ category: String?) -> [String]
    {
        return CIFilter.filterNames(inCategory: category).filter
        {
            !exclusions.contains($0)
        }
    }
    
    func supportedFilterNamesInCategories(_ categories: [String]?) -> [String]
    {
        return CIFilter.filterNames(inCategories: categories).filter
        {
            !exclusions.contains($0)
        }
    }
}

// MARK: UITableViewDataSource extension

extension FilterNavigator: UITableViewDataSource
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        switch mode
        {
        case .Grouped:
            return filterCategories.count
        case .Flat:
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        switch mode
        {
        case .Grouped:
            return supportedFilterNamesInCategory(filterCategories[section]).count
        case .Flat:
            return supportedFilterNamesInCategories(nil).count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemRenderer",
            for: indexPath) 

        let filterName: String
        
        switch mode
        {
        case .Grouped:
            filterName = supportedFilterNamesInCategory(filterCategories[indexPath.section]).sorted()[indexPath.row]
        case .Flat:
            filterName = supportedFilterNamesInCategories(nil).sorted
            {
                CIFilter.localizedName(forFilterName: $0) ?? $0 < CIFilter.localizedName(forFilterName: $1) ?? $1
            }[indexPath.row]
        }
        
        cell.textLabel?.text = CIFilter.localizedName(forFilterName: filterName) ?? (CIFilter(name: filterName)?.attributes[kCIAttributeFilterDisplayName] as? String) ?? filterName
        
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
    func filterNavigator(_ filterNavigator: FilterNavigator, didSelectFilterName: String)
}

