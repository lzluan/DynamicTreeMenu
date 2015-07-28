//
//  ViewController.swift
//  MFTreeView
//
//  Created by shzlliu on 15/7/20.
//  Copyright (c) 2015. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DynamicTreeMenuDataSource, DynamicTreeMenuDelegate {
    @IBOutlet weak var treeMenu: DynamicTreeMenu!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var rootNode = DynamicTreeNode(name: "rootNode")
        var node0 = DynamicTreeNode(name: "Node0")
        var node00 = DynamicTreeNode(name: "Node00")
        node0.addChild(node00)
        node0.addChild(DynamicTreeNode(name: "Node01"))
        node0.addChild(DynamicTreeNode(name: "Node02"))
        
        node00.addChild(DynamicTreeNode(name: "Node000"))
        node00.addChild(DynamicTreeNode(name: "Node001"))
        node00.addChild(DynamicTreeNode(name: "Node002"))
        node00.addChild(DynamicTreeNode(name: "Node003"))
        
        rootNode.addChild(node0)
        rootNode.addChild(DynamicTreeNode(name: "Node1"))
        rootNode.addChild(DynamicTreeNode(name: "Node2"))
        rootNode.addChild(DynamicTreeNode(name: "Node3"))
        rootNode.addChild(DynamicTreeNode(name: "Node4"))
        
        treeMenu.rootNode = rootNode
        treeMenu.dataSource = self
        treeMenu.delegate = self
        
        let nib = UINib(nibName: "DynamicTreeCell", bundle: nil)
        treeMenu.registerNib(nib, forCellReuseIdentifier: "CellId")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: DynamicTreeMenuDataSource
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, cellForTreeNode treeNode: DynamicTreeNode, indexPath: NSIndexPath) -> UITableViewCell {
        var cell = treeMenu.dequeueReusableCellWithIdentifier("CellId", forIndexPath: indexPath) as! DynamicTreeCell
        cell.selectionStyle = .None
        
        cell.switchButton.addTarget(self, action: "switchButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.addButton.addTarget(self, action: "addButtonTapped:", forControlEvents: UIControlEvents.TouchUpInside)
        cell.levelConstraint.constant = 10 + CGFloat(treeNode.level() - 1) * 20
        cell.nameLabel.text = "\(treeNode.name): \(treeNode.children.count)"
        
        return cell
    }
    
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, heightForTreeNode treeNode: DynamicTreeNode) -> CGFloat {
        return 60
    }
    
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, canEditTreeNode treeNode:DynamicTreeNode) -> Bool {
        return true
    }
    
    func indexPathForButton(button: UIButton) -> NSIndexPath {
        var p = button.superview
        while !(p!.isKindOfClass(UITableViewCell.self)) {
            p = p!.superview
        }
        return treeMenu.indexPathForCell(p as! UITableViewCell)!
    }
    
    @IBAction func switchButtonTapped(sender: AnyObject) {
        var indexPath = self.indexPathForButton(sender as! UIButton)
        treeMenu.switchRowAtIndexPath(indexPath)
    }
    
    @IBAction func addButtonTapped(sender: AnyObject) {
        var indexPath = self.indexPathForButton(sender as! UIButton)
        treeMenu.addSubRow(DynamicTreeNode(name: "New"), indexPath: indexPath)
    }
    
    //MARK: DynamicTreeMenuDelegate
    func dynamicTreeMenu(dynamicTreeMenu: DynamicTreeMenu, didSelectTreeNode treeNode: DynamicTreeNode) {
        println(treeNode.name)
    }
}

