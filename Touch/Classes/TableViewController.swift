// MIT License
//
// Copyright (c) Uottakuot Software
// https://github.com/uottakuot/RapidKit
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

open class TableViewController: BaseViewController {
    @IBOutlet
    public var tableView: UITableView!
    
    public private(set) var allCellSources: [TableViewCellSource] = []
    
    open var defaultCellClass: CustomTableViewCell.Type {
        return CustomTableViewCell.self
    }
    
    public var deselectsRows = true
    
    public var rowDeselectionDelay: TimeInterval = 0.2
    
    open override var hasData: Bool {
        return allCellSources.count > 0
    }
    
    public var activeIndexPath: IndexPath? {
        guard let firstResponder = tableView.firstResponder else {
            return nil
        }
        
        var parentView = firstResponder.superview
        while parentView != nil {
            if parentView is UITableViewCell {
                break
            }
            
            parentView = parentView?.superview
        }
        
        guard let cell = parentView as? UITableViewCell else {
            return nil
        }
        
        return tableView.indexPath(for: cell)
    }
    
    public var usesRefreshControl: Bool = false {
        didSet {
            if usesRefreshControl && tableView.refreshControl == nil {
                tableView.refreshControl = UIRefreshControl()
                tableView.refreshControl?.addTarget(self, action: #selector(reloadWithRefreshControl), for: .valueChanged)
            } else if !usesRefreshControl {
                tableView.refreshControl = nil
            }
        }
    }
    
    open func addCellSource(_ source: TableViewCellSource) {
        allCellSources.append(source)
    }
    
    public func addCellSources(_ sources: [TableViewCellSource]) {
        for source in sources {
            addCellSource(source)
        }
    }
    
    public func removeAllCellSources() {
        allCellSources = []
    }
    
    public func indexPath(for source: TableViewCellSource) -> IndexPath? {
        guard let index = allCellSources.firstIndex(of: source) else {
            return nil
        }
        
        return IndexPath(row: index, section: 0)
    }
    
    public func cellSource(for indexPath: IndexPath) -> TableViewCellSource? {
        return allCellSources[indexPath.row]
    }
    
    public func cellSource<T: AnyObject>(for data: T)  -> TableViewCellSource? {
        return allCellSources.filter { data === $0.data as? T }.last
    }
    
    public func cellSource<T: Equatable>(for data: T)  -> TableViewCellSource? {
        return allCellSources.filter { data == $0.data as? T }.last
    }
    
    public func reloadTable(animated: Bool, completion: (() -> Void)? = nil) {
        willReloadTable()
        
        if animated && activeIndexPath == nil {
            UIView.transition(with: tableView, duration: 0.18, options: [.beginFromCurrentState, .allowUserInteraction, .transitionCrossDissolve]) {
                self.tableView.reloadData()
            } completion: { finished in
                completion?()
                
                self.didReloadTable()
            }
        } else {
            tableView.reloadData()
            
            completion?()
            
            self.didReloadTable()
        }
        
        refreshNoDataInfo()
    }
    
    open func willReloadTable() {
        //
    }
    
    open func didReloadTable() {
        //
    }
    
    public func reloadCellSources(_ sources: [TableViewCellSource], with animation: UITableView.RowAnimation) {
        let indexPaths = sources.compactMap { indexPath(for: $0) }
        tableView.reloadRows(at: indexPaths, with: animation)
    }
    
    public func insertRows(for sources: [TableViewCellSource], at indexPaths: [IndexPath], with animation: UITableView.RowAnimation = .none) {
        for i in 0 ..< sources.count {
            let indexPath = indexPaths[i]
            let source = sources[i]
            
            tableView.insertRows(at: [indexPath], with: animation)
            allCellSources.insert(source, at: indexPath.row)
        }
    }
    
    public func insertRows(for sources: [TableViewCellSource], after indexPath: IndexPath, with animation: UITableView.RowAnimation) {
        var indexPaths: [IndexPath] = []
        for i in 0 ..< sources.count {
            indexPaths.append(IndexPath(row: indexPath.row + 1 + i, section: indexPath.section))
        }
        
        insertRows(for: sources, at: indexPaths, with: animation)
    }
    
    public func deleteRows(for sources: [TableViewCellSource], with animation: UITableView.RowAnimation) {
        let indexPaths = sources.compactMap { indexPath(for: $0) }
        
        for source in sources {
            allCellSources.remove(source)
        }
        
        if indexPaths.count > 0 {
            tableView.deleteRows(at: indexPaths, with: animation)
        }
    }
    
    public func estimatedHeightForCellSources(_ sources: [TableViewCellSource]) -> CGFloat {
        var height: CGFloat = 0
        
        for source in sources {
            if let calculate = source.willCalculateContentHeight {
                guard let indexPath = self.indexPath(for: source) else {
                    continue
                }
                
                let insets = source.contentViewInsets
                var constraints = CGSize(width: tableView.frame.size.width - insets.left - insets.right, height: .greatestFiniteMagnitude)
                if #available(iOS 11.0, *) {
                    constraints.width -= tableView.safeAreaInsets.left + tableView.safeAreaInsets.right
                }
                
                let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: nil)
                height += calculate(callbackInfo, constraints) + insets.top + insets.bottom
            } else if let calculate = source.willCalculateHeight {
                guard let indexPath = self.indexPath(for: source) else {
                    continue
                }
                
                let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: nil)
                calculate(callbackInfo)
                
                height += source.rowHeight ?? 0
            } else if let rowHeight = source.rowHeight, rowHeight > 0 {
                height += rowHeight
            } else if let contentView = source.contentView, source.usesContentViewHeight {
                height += contentView.frame.size.height + source.contentViewInsets.top + source.contentViewInsets.bottom
            } else {
                height += tableView.rowHeight
            }
        }
        
        return height
    }
    
    public func dynamicHeightCalculation() -> TableViewCellSource.Callback {
        return { (info: TableViewCellSource.CallbackInfo) -> Void in
            var sources = self.allCellSources
            sources.remove(info.cellSource)
            
            let tableView = info.controller.tableView!
            
            var height = tableView.frame.size.height
                        - self.estimatedHeightForCellSources(sources)
                        - tableView.contentInset.top
                        - tableView.contentInset.bottom
            
            if #available(iOS 11.0, *) {
                height -= tableView.safeAreaInsets.top + tableView.safeAreaInsets.bottom
            }
            
            if (height <= 0) {
                height = 1
            }
            
            info.cellSource.rowHeight = height
        }
    }
    
    private func copySkins(fromCell cell: UITableViewCell, toCellSource source: TableViewCellSource) {
        if source.textSkin == nil {
            source.textSkin = cell.textLabel?.skin as? TextSkin
        }
        
        if source.detailSkin == nil {
            source.detailSkin = cell.detailTextLabel?.skin as? TextSkin
        }
        
        if source.imageSkin == nil {
            source.imageSkin = cell.imageView?.skin
        }
    }
    
    private func applySource(_ source: TableViewCellSource, toCell cell: CustomTableViewCell) {
        cell.textLabel?.text = source.text
        cell.detailTextLabel?.text = source.detailText
        cell.selectionStyle = source.selectionStyle
        
        if source.accessoryView != nil {
            cell.accessoryView = source.accessoryView
        } else {
            cell.accessoryType = source.accessoryType
        }
        
        if source.editingAccessoryView != nil {
            cell.editingAccessoryView = source.editingAccessoryView
        } else {
            cell.editingAccessoryType = source.editingAccessoryType
        }
        
        if source.cellSkin != nil {
            cell.skin = source.cellSkin
        }
        
        cell.textLabel?.skin = source.textSkin
        cell.textLabel?.numberOfLines = source.numberOfTextLines
        cell.detailTextLabel?.skin = source.detailSkin
        cell.detailTextLabel?.numberOfLines = source.numberOfDetailTextLines
        cell.imageView?.skin = source.imageSkin
        cell.imageView?.image = source.image
        cell.topLineView.isHidden = !source.showsTopLine
        cell.topLineInsets = source.topLineInsets
        cell.topLineView.lineColor = source.topLineColor ?? .lightGray
        cell.bottomLineView.isHidden = !source.showsBottomLine
        cell.bottomLineInsets = source.bottomLineInsets
        cell.bottomLineView.lineColor = source.bottomLineColor ?? .lightGray
    }
    
    @objc
    private func reloadWithRefreshControl() {
        self.reloadData {
            DispatchQueue.main.async {
                self.tableView.refreshControl?.endRefreshing()
            }
        }
    }
}

extension TableViewController: UITableViewDataSource {
    open func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard hasData else {
            return 0
        }
        
        return allCellSources.count
    }
    
    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let source = cellSource(for: indexPath) {
            if let reuseIdentifier = source.reuseIdentifier {
                if let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? CustomTableViewCell {
                    copySkins(fromCell: cell, toCellSource: source)
                    return cell
                }
            }
            
            let cellClass = source.cellClass ?? defaultCellClass
            let cell = cellClass.init(style: source.cellStyle, reuseIdentifier: source.reuseIdentifier)
            
            if source.didLayoutSubviews != nil {
                cell.delegate = self
            }
            
            copySkins(fromCell: cell, toCellSource: source)
            applySource(source, toCell: cell)
            
            cell.customContentView = source.contentView
            cell.customContentViewInsets = source.contentViewInsets
            
            let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: cell)
            source.didCreateCell?(callbackInfo)
            
            return cell
        }
        
        return CustomTableViewCell()
    }
}

extension TableViewController: UITableViewDelegate {
    open func tableView(_ tableView: UITableView, willDisplay tableCell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let source = cellSource(for: indexPath), let cell = tableCell as? CustomTableViewCell {
            if source.reuseIdentifier != nil {
                applySource(source, toCell: cell)
            }
            
            let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: cell)
            source.willDisplayCell?(callbackInfo)
        }
    }
    
    open func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let source = cellSource(for: indexPath) {
            if source.usesContentViewHeight, let view = source.contentView {
                let insets = source.contentViewInsets
                return view.frame.size.height + insets.top + insets.bottom
            }
            
            if source.willCalculateContentHeight != nil {
                let insets = source.contentViewInsets
                
                var constraints = CGSize(width: tableView.frame.size.width - insets.left - insets.right, height: .greatestFiniteMagnitude)
                if #available(iOS 11.0, *) {
                    constraints.width -= tableView.safeAreaInsets.left + tableView.safeAreaInsets.right
                }
                
                let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: nil)
                
                var height = source.willCalculateContentHeight!(callbackInfo, constraints) + insets.top + insets.bottom
                if let minRowHeight = source.minRowHeight, height < minRowHeight {
                    height = minRowHeight
                }
                
                source.rowHeight = height
            } else if source.willCalculateHeight != nil {
                let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: nil)
                source.willCalculateHeight?(callbackInfo)
            }
            
            if let rowHeight = source.rowHeight {
                return rowHeight
            }
        }
        
        return tableView.rowHeight
    }
    
    open func tableView(_ tableView: UITableView, didHighlightRowAt indexPath: IndexPath) {
        if let source = cellSource(for: indexPath) {
            let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell
            let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: cell)
            source.didHighlightCell?(callbackInfo)
        }
    }
    
    open func tableView(_ tableView: UITableView, didUnhighlightRowAt indexPath: IndexPath) {
        if let source = cellSource(for: indexPath) {
            let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell
            let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: cell)
            source.didUnhighlightCell?(callbackInfo)
        }
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if deselectsRows {
            DispatchQueue.main.asyncAfter(delay: rowDeselectionDelay) {
                tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        if let source = cellSource(for: indexPath) {
            let cell = tableView.cellForRow(at: indexPath) as? CustomTableViewCell
            let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: cell)
            source.didSelectCell?(callbackInfo)
        }
    }
}

extension TableViewController: CustomTableViewCellDelegate {
    public func customTableViewCellDidLayoutSubviews(_ cell: CustomTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell), let source = cellSource(for: indexPath) else {
            return
        }
        
        let callbackInfo = TableViewCellSource.CallbackInfo(controller: self, indexPath: indexPath, cellSource: source, cell: cell)
        source.didLayoutSubviews?(callbackInfo)
    }
}
