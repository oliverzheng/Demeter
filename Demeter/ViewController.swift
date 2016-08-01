//
//  ViewController.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/29/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
  
  @IBOutlet var textView: NSTextView!
  
  @IBOutlet weak var outlineView: NSOutlineView!
  
  var localFileSource: LocalFileSource?
  var sshFileSource: SSHFileSource?
  var fileSource: FileSource?
  
  @IBAction func onLocalButtonPush(sender: AnyObject) {
    let fileDialog = NSOpenPanel()
    fileDialog.canChooseDirectories = true
    fileDialog.canChooseFiles = false
    fileDialog.runModal()
    
    let url = fileDialog.URL

    print(url)
    
    let localFileSource = LocalFileSource(rootURL: url!)
    localFileSource.listFilesInDirectory(localFileSource.rootDirectoryFile) {
      let paths = $0.map { file -> String in file.relativePath }
      let allPaths = paths.joinWithSeparator("\n")
      self.textView.string = allPaths
    }
    self.localFileSource = localFileSource
  }
  
  @IBAction func onRemoteButtonPush(sender: AnyObject) {
    let sshFileSource = SSHFileSource(username: "oliver", host: "phatbaby.mooo.com", rootURL: NSURL(fileURLWithPath: "/home/oliver/tmp/", isDirectory: true))
    let isAvailable = sshFileSource.isAvailable
    textView.string = isAvailable ? "available" : "not available"
    
    sshFileSource.listFilesInDirectory(sshFileSource.rootDirectoryFile) {
      let paths = $0.map { file -> String in file.relativePath }
      let allPaths = paths.joinWithSeparator("\n")
      self.textView.string = allPaths
    }
    
    self.sshFileSource = sshFileSource
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    localFileSource = LocalFileSource(rootURL: NSURL(fileURLWithPath: "/Users/oliverzheng/tmp/", isDirectory: true))

    sshFileSource = SSHFileSource(username: "oliver", host: "phatbaby.mooo.com", rootURL: NSURL(fileURLWithPath: "/home/oliver/tmp/", isDirectory: true))

    fileSource = sshFileSource
    
    // Do any additional setup after loading the view.
    textView.string = "herp derp"
  }

  override var representedObject: AnyObject? {
    didSet {
    // Update the view, if already loaded.
    }
  }
}

extension ViewController: NSOutlineViewDataSource {
  
  func outlineView(outlineView: NSOutlineView, child index: Int, ofItem item: AnyObject?) -> AnyObject {
    if let file = item as? File {
      return file.childrenFiles![index]
    } else {
      return fileSource!.rootDirectoryFile
    }
  }
  
  func outlineView(outlineView: NSOutlineView, isItemExpandable item: AnyObject) -> Bool {
    if let file = item as? File {
      return file.isDirectory
    }
    return true
  }
  
  func outlineView(outlineView: NSOutlineView, numberOfChildrenOfItem item: AnyObject?) -> Int {
    if let file = item as? File {
      return file.childrenFiles?.count ?? 0
    }
    return 1
  }
}

extension ViewController: NSOutlineViewDelegate {
  
  func outlineView(outlineView: NSOutlineView, viewForTableColumn: NSTableColumn?, item: AnyObject) -> NSView? {
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
 