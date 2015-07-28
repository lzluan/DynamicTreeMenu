//
//  DynamicTreeMenu.swift
//  DynamicTreeMenu
//
//  Created by shzlliu on 15/7/20.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

protocol DynamicTreeMenuDataSource: NSObjectProtocol {
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, cellForTreeNode treeNode:DynamicTreeNode, indexPath: NSIndexPath) -> UITableViewCell
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, heightForTreeNode treeNode:DynamicTreeNode) -> CGFloat
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, canEditTreeNode treeNode:DynamicTreeNode) -> Bool
}

protocol DynamicTreeMenuDelegate: NSObjectProtocol {
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, didSelectTreeNode treeNode:DynamicTreeNode)
}

class DynamicTreeMenu: UIView, UITableViewDataSource, UITableViewDelegate{
    var treeView: UITableView!
    var rootNode: DynamicTreeNode?
    weak var dataSource: DynamicTreeMenuDataSource?
    weak var delegate: DynamicTreeMenuDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        treeView = UITableView()
        treeView.dataSource = self
        treeView.delegate = self
        treeView.tableFooterView = UIView()
        
        addSubview(treeView)
        
        treeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        
        let nameMap = ["treeView": treeView]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-0-[treeView]-0-|",
            options: .allZeros,
            metrics: nil, views: nameMap))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-0-[treeView]-0-|",
            options: .allZeros,
            metrics: nil, views: nameMap))
    }
    
    private func allExpandedNodes() -> NSArray {
        var allNodes: NSMutableArray = NSMutableArray()
        if let rootNode = rootNode {
            for node in rootNode.children {
                allNodes.addObjectsFromArray(self.expandedNodes(node) as! [DynamicTreeNode])
            }
        }
        
        return allNodes
    }
    
    private func treeNodeForIndexPath(indexPath: NSIndexPath) -> DynamicTreeNode {
        //todo: optimize it
        var allNodes = allExpandedNodes()
        
        return allNodes.objectAtIndex(indexPath.row) as! DynamicTreeNode
    }
    
    private func indexPathForTreeNode(treeNode: DynamicTreeNode) -> NSIndexPath? {
        //todo: optimize it
        var allNodes = allExpandedNodes()
        var index = allNodes.indexOfObject(treeNode)
        
        return (index < allNodes.count) ? NSIndexPath(forRow: index, inSection: 0) : nil
    }
    
    private func expandedNodes(treeNode: DynamicTreeNode) -> NSArray {
        var array: NSMutableArray = NSMutableArray()
        array.addObject(treeNode)
        if treeNode.expanded {
            for node in treeNode.children {
                array.addObjectsFromArray(self.expandedNodes(node) as! [DynamicTreeNode])
            }
        }
        
        return array
    }
    
    func registerNib(nib: UINib, forCellReuseIdentifier identifier: String) {
        treeView.registerNib(nib, forCellReuseIdentifier: identifier)
    }
    func registerClass(cellClass: AnyClass, forCellReuseIdentifier identifier: String) {
        treeView.registerClass(cellClass, forCellReuseIdentifier: identifier)
    }
    
    func dequeueReusableCellWithIdentifier(identifier: String, forIndexPath indexPath: NSIndexPath) -> AnyObject {
        return treeView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath)
    }
    
    //MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var allNodes = allExpandedNodes()
        return allNodes.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return (dataSource != nil) ? dataSource!.dynamicTreeMenu(self, cellForTreeNode: treeNodeForIndexPath(indexPath), indexPath: indexPath) : UITableViewCell()
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return (dataSource != nil) ? dataSource!.dynamicTreeMenu(self, heightForTreeNode: treeNodeForIndexPath(indexPath)) : 44.0
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return (dataSource != nil) ? dataSource!.dynamicTreeMenu(self, canEditTreeNode: treeNodeForIndexPath(indexPath)) : false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        var node = self.treeNodeForIndexPath(indexPath)
        delegate?.dynamicTreeMenu(self, didSelectTreeNode: node)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        let remove = UITableViewRowAction(style: .Default, title: "Remove", handler: {[weak self](action, indexPath) -> Void in
            if let theSelf = self {
                theSelf.deleteRow(indexPath)
            }
            })
        remove.backgroundColor = UIColor.redColor()
        
        return [remove]
    }
    
    func switchRowAtIndexPath(indexPath: NSIndexPath) {
        var node = self.treeNodeForIndexPath(indexPath)
        if node.expanded {
            self.collapseRowForTreeNode(node, indexPath: indexPath)
        } else {
            self.expandRowForTreeNode(node, indexPath: indexPath)
        }
    }
    
    private func collapseRowForTreeNode(treeNode: DynamicTreeNode, indexPath: NSIndexPath) {
        if treeNode.hasChildren() {
            var expandedNodes = self.expandedNodes(treeNode)
            
            treeNode.expanded = false
            
            var indexPaths:[NSIndexPath] = []
            for i in 1..<expandedNodes.count {
                indexPaths.append(NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section))
                var node = expandedNodes.objectAtIndex(i) as! DynamicTreeNode
                node.expanded = false
            }
            
            treeView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
    
    private func expandRowForTreeNode(treeNode: DynamicTreeNode, indexPath: NSIndexPath) {
        if treeNode.hasChildren() {
            treeNode.expanded = true
            
            var indexPaths:[NSIndexPath] = []
            for i in 1..<(treeNode.children.count + 1) {
                indexPaths.append(NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section))
            }
            
            treeView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        }
    }
    
    func addSubRow(treeNode: DynamicTreeNode, indexPath: NSIndexPath) {
        var node = self.treeNodeForIndexPath(indexPath)
        node.insert(treeNode, atIndex: 0)
        if node.expanded {
            treeView.insertRowsAtIndexPaths([NSIndexPath(forRow: indexPath.row + 1, inSection: indexPath.section)], withRowAnimation: .Fade)
        } else {
            expandRowForTreeNode(node, indexPath: indexPath)
        }
        
        //update parent
        treeView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    func deleteRow(indexPath: NSIndexPath) {
        var node = self.treeNodeForIndexPath(indexPath)
        var expandedNodes = self.expandedNodes(node)
        
        var indexPaths:[NSIndexPath] = []
        for i in 0..<expandedNodes.count {
            indexPaths.append(NSIndexPath(forRow: indexPath.row + i, inSection: indexPath.section))
        }
        
        node.removeFromParent()
        treeView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Fade)
        
        //update parent
        if node.parent != nil {
            if let p = self.indexPathForTreeNode(node.parent!) {
                treeView.reloadRowsAtIndexPaths([p], withRowAnimation: .None)
            }
        }
    }
    
    func indexPathForCell(cell: UITableViewCell) -> NSIndexPath? {
        return treeView.indexPathForCell(cell)
    }
    
    func reloadData() {
        treeView.reloadData()
    }
}
