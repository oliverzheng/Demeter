//
//  SSHFileSource.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/31/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Foundation

class SSHFileSource: FileSource {
  
  private var username: String
  private var host: String
  private(set) var rootURL: NSURL
  
  init(
    username: String,
    host: String,
    rootURL: NSURL
    ) {
    self.username = username
    self.host = host
    self.rootURL = rootURL
  }

  var isAvailable: Bool {
    let task = NSTask()
    task.launchPath = "/usr/bin/ssh"
    task.arguments = ["-S", "/tmp/%r@%h:%p", "\(username)@\(host)", "-O", "check"]
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus == 0
  }
  
  lazy var rootDirectoryFile: File = {
    return RemoteFile(fileSource: self, relativePath: "/", isDirectory: true)
  }()
  
  func listFilesInDirectory(directory: File, callback: ([File]) -> Void) -> Void {
    let task = NSTask()
    task.launchPath = "/usr/bin/ssh"
    task.arguments = ["-S", "/tmp/%r@%h:%p", "\(username)@\(host)", "ls -p1 \(directory.absolutePath)"]
    
    let pipe = NSPipe()
    task.standardOutput = pipe
    
    task.terminationHandler = {_ in
      let handle = pipe.fileHandleForReading
      let output = String(data: handle.readDataToEndOfFile(), encoding: NSUTF8StringEncoding)!
      let files = output.componentsSeparatedByString("\n").map {line -> File in
        let isDirectory = line.hasSuffix("/")

        let absolutePath = NSString.pathWithComponents([directory.absolutePath, line])
        let relativePath = self.getRelativePath(absolutePath)!
        
        return RemoteFile(
          fileSource: self,
          relativePath: relativePath,
          isDirectory: isDirectory
        )
      }
      dispatch_async(dispatch_get_main_queue()) {
        directory.childrenFiles = files
        callback(files)
      }
    }
    
    task.launch()
  }
  
  func getRelativePath(absolutePath: String) -> String? {
    if !absolutePath.hasPrefix(rootURL.path!) {
      return nil
    }
    
    let index = absolutePath.startIndex.advancedBy(rootURL.path!.characters.count)
    return absolutePath.substringFromIndex(index)
  }
  
  func copy(file: File, localPath: String, copyCompleteHandler: () -> Void) -> Void {
    if file.fileSource !== self {
      return
    }
    let remoteFile = file as! RemoteFile

    let task = NSTask()
    task.launchPath = "/usr/bin/scp"
    task.arguments = ["-o", "ControlPath=/tmp/%r@%h:%p", "\(username)@\(host):\(remoteFile.absolutePath)", "\(localPath)"]
    task.terminationHandler = {_ in
      dispatch_async(dispatch_get_main_queue()) {
        copyCompleteHandler()
      }
    }
    task.launch()
  }
}