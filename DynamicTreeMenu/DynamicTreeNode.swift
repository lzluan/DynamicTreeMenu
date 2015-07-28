//
//  DynamicTreeNode.swift
//  DynamicTreeMenu
//
//  Created by shzlliu on 15/7/20.
//  Copyright (c) 2015. All rights reserved.
//

import Foundation

class DynamicTreeNode: NSObject {
    var name: String = ""
    var parent: DynamicTreeNode?
    var children: [DynamicTreeNode] = []
    var userData: NSMutableDictionary?
    private var expand: Bool = false
    
    init(name: String) {
        super.init()
        self.name = name
    }
    
    var expanded: Bool {
        set {
            self.expand = newValue
        }
        get {
            return self.expand || (!self.hasChildren())
        }
    }
    
    func level() -> Int {
        var n = 0
        var p = parent
        while p != nil {
            n++
            p = p!.parent
        }
        return n
    }
    
    func hasChildren() -> Bool {
        return children.count > 0
    }
    
    func addChild(child: DynamicTreeNode) {
        self.children.append(child)
        child.parent = self
    }
    
    func insert(child: DynamicTreeNode, atIndex i: Int) {
        self.children.insert(child, atIndex: i)
        child.parent = self
    }
    
    func removeFromParent() {
        if parent != nil {
            if let indexToRemove = find(parent!.children, self) {
                parent!.children.removeAtIndex(indexToRemove)
            }
        }
    }
}
