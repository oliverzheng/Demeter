//
//  ViewController.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/29/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  @IBOutlet weak var outlineView: NSOutlineView!
  @IBOutlet weak var localDirectoryTextField: NSTextField!
  @IBOutlet weak var sshUserTextField: NSTextField!
  @IBOutlet weak var sshHostTextField: NSTextField!
  @IBOutlet weak var sshRemoteDirectoryTextField: NSTextField!
  @IBOutlet weak var sshCacheDirectoryTextField: NSTextField!
  @IBOutlet weak var sshConnectButton: NSButton!
  @IBOutlet weak var sshConnectionStatusTextField: NSTextField!
  
  var isSSHConnected: Bool = false
  
  var currentFileSource: FileSource?
  var localCacheFileSource: LocalFileSource?
  
  private func resetFileSources() {
    currentFileSource = nil
    localCacheFileSource = nil
    
    sshConnectionStatusTextField.stringValue = "Disconnected"
    sshConnectButton.title = "Connect"
    isSSHConnected = false

    outlineView.reloadData()
  }
  
  @IBAction func onLocalDirectoryBrowsePush(sender: AnyObject) {
    let fileDialog = NSOpenPanel()
    fileDialog.canChooseDirectories = true
    fileDialog.canChooseFiles = false
    fileDialog.runModal()
    
    let optionalUrl = fileDialog.URL
    if let url = optionalUrl {
      self.resetFileSources()
      
      localDirectoryTextField.stringValue = url.absoluteString
      currentFileSource = LocalFileSource(rootURL: url)
      
      outlineView.reloadData()
    }
  }
  
  @IBAction func onSSHCacheDirectoryBrowsePush(sender: AnyObject) {
    let fileDialog = NSOpenPanel()
    fileDialog.canChooseDirectories = true
    fileDialog.canChooseFiles = false
    fileDialog.runModal()
    
    let optionalUrl = fileDialog.URL
    if let url = optionalUrl {
      sshCacheDirectoryTextField.stringValue = url.absoluteString
    }
  }

  @IBAction func onSSHConnectButtonPush(sender: AnyObject) {
    if isSSHConnected {
      resetFileSources()
      return
    }
    
    let user = sshUserTextField.stringValue
    let host = sshHostTextField.stringValue
    let remoteDirectory = sshRemoteDirectoryTextField.stringValue
    let cacheDirectory = sshCacheDirectoryTextField.stringValue
    if (
      user.isEmpty ||
      host.isEmpty ||
      remoteDirectory.isEmpty ||
      cacheDirectory.isEmpty
    ) {
      return
    }
    
    resetFileSources()
    
    currentFileSource = SSHFileSource(username: user, host: host, rootURL: NSURL(fileURLWithPath: remoteDirectory, isDirectory: true))
    localCacheFileSource = LocalFileSource(rootURL: NSURL(fileURLWithPath: cacheDirectory))
    
    if currentFileSource!.isAvailable {
      sshConnectionStatusTextField.stringValue = "Connected"

      sshConnectButton.title = "Disconnect"
      isSSHConnected = true
      
      saveSSHFieldsToPreferences()
      
      outlineView.reloadData()
    } else {
      resetFileSources()
      
      sshConnectionStatusTextField.stringValue = "Connection Error"
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    populateSSHFieldsFromPreferences()
  }
  
  private func populateSSHFieldsFromPreferences() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    if let sshUser = userDefaults.stringForKey("sshUser") {
      sshUserTextField.stringValue = sshUser
    }
    if let sshHost = userDefaults.stringForKey("sshHost") {
      sshHostTextField.stringValue = sshHost
    }
    if let sshRemoteDirectory = userDefaults.stringForKey("sshRemoteDirectory") {
      sshRemoteDirectoryTextField.stringValue = sshRemoteDirectory
    }
    if let sshLocalCacheDirectory = userDefaults.stringForKey("sshLocalCacheDirectory") {
      sshCacheDirectoryTextField.stringValue = sshLocalCacheDirectory
    }
  }
  
  private func saveSSHFieldsToPreferences() {
    let userDefaults = NSUserDefaults.standardUserDefaults()
    userDefaults.setObject(sshUserTextField.stringValue, forKey: "sshUser")
    userDefaults.setObject(sshHostTextField.stringValue, forKey: "sshHost")
    userDefaults.setObject(sshRemoteDirectoryTextField.stringValue, forKey: "sshRemoteDirectory")
    userDefaults.setObject(sshCacheDirectoryTextField.stringValue, forKey: "sshLocalCacheDirectory")
    userDefaults.synchronize()
  }
}

extension ViewController: NSOutlineViewDataSource {
  
  func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
    if let file = item as? File {
      return file.childrenFiles![index]
    } else {
      return currentFileSource!.rootDirectoryFile
    }
  }
  
  func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
    if let file = item as? File {
      return file.isDirectory
    }
    return true
  }
  
  func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
    if self.currentFileSource == nil {
      return 0
    }
    
    if let file = item as? File {
      return file.childrenFiles?.count ?? 0
    }
    return 1
  }
}

extension ViewController: NSOutlineViewDelegate {
  
  func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
    if self.currentFileSource == nil {
      return nil
    }
    
    let view = outlineView.makeViewWithIdentifier("FileCell", owner: self) as! NSTableCellView
    if let file = item as? File {
      if let textField = view.textField {
        textField.stringValue = file.filename
      }
      return view
    } else {
      if let textField = view.textField {
        textField.stringValue = "/"
      }
      
    }
    return view
  }
  
  func outlineViewItemWillExpand(notification: NSNotification) {
    let file = notification.userInfo?["NSObject"] as! File
    if file.childrenFiles == nil {
      file.fileSource.listFilesInDirectory(file) {_ in
        self.outlineView.reloadData()
      }
    }
  }

}
 