//
//  AdvPreferencesWindowController.swift
//  ShadowsocksX-NG
//
//  Created by 邱宇舟 on 16/6/6.
//  Copyright © 2016年 qiuyuzhou. All rights reserved.
//

import Cocoa

class AdvPreferencesWindowController: NSWindowController, NSTableViewDataSource, NSTableViewDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    
    var networkServices: NSArray!
    var selectedNetworkServices: NSMutableSet!
    
    override func windowDidLoad() {
        super.windowDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let defaults = UserDefaults.standard
        if let services = defaults.array(forKey: USERDEFAULTS_PROXY4_NETWORK_SERVICES) {
            selectedNetworkServices = NSMutableSet(array: services)
        } else {
            selectedNetworkServices = NSMutableSet()
        }
        networkServices = ProxyConfTool.networkServicesList() as NSArray?
        tableView.reloadData()
    }
    
    @IBAction func ok(_ sender: NSButton) {
        ProxyConfHelper.disableProxy("hi")
        
        let defaults = UserDefaults.standard
        defaults.setValue(selectedNetworkServices.allObjects, forKeyPath: USERDEFAULTS_PROXY4_NETWORK_SERVICES)
        defaults.synchronize()
        
        window?.performClose(self)
        
        NotificationCenter.default.post(name: NOTIFY_ADV_CONF_CHANGED, object: nil)
        NotificationCenter.default.post(name: NOTIFY_ADV_PROXY_CONF_CHANGED, object: nil)
    }
    
    @IBAction func cancel(_ sender: NSButton) {
        window?.performClose(self)
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        if networkServices != nil {
            return networkServices.count
        }
        return 0;
    }
        
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let cell = tableColumn!.dataCell as! NSButtonCell
        
        let key = (networkServices[row] as AnyObject)["key"] as! String
        if selectedNetworkServices.contains(key) {
            cell.state = NSControl.StateValue(rawValue: 1)
        } else {
            cell.state = NSControl.StateValue(rawValue: 0)
        }
        let userDefinedName = (networkServices[row] as AnyObject)["userDefinedName"] as! String
        cell.title = userDefinedName
        return cell
    }
    
    func tableView(_ tableView: NSTableView, setObjectValue object: Any?, for tableColumn: NSTableColumn?, row: Int) {
        let key = (networkServices[row] as AnyObject)["key"] as! String
        
        if (object! as AnyObject).intValue == 1 {
            selectedNetworkServices.add(key)
        } else {
            selectedNetworkServices.remove(key)
        }
    }
}
