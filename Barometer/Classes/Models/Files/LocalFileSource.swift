//
//  LocalFileSource.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/29/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Foundation

class LocalFileSource: FileSource {
  
  private(set) var rootURL: NSURL
  
  init(rootURL: NSURL) {
    self.rootURL = rootURL
  }
  
  // FileSource
  
  var isAvailable: Bool {
    var isDir: ObjCBool = false;
    let fm = NSFileManager.defaultManager()
    if fm.fileExistsAtPath(rootURL.path!, isDirectory: &isDir) {
      if (isDir) {
        return true
      } else {
        return false
      }
    } else {
      return false
    }
  }

  lazy var rootDirectoryFile: File = {
    return LocalFile(fileSource: self, relativePath: "/", isDirectory: true)
  }()
  
  func listFilesInDirectory(directory: File, callback: ([File]) -> Void) -> Void {
    if directory.fileSource !== self {
      return
    }
    if !directory.isDirectory {
      return
    }
    if (directory as? LocalFile) == nil {
      return
    }
    
    let localDirectory = directory as! LocalFile
    
    let fm = NSFileManager.defaultManager()
    do {
      let filepaths = try fm.contentsOfDirectoryAtPath(localDirectory.absolutePath);
      let files = filepaths.map { filepath -> File in
        let absolutePath = NSString.pathWithComponents([localDirectory.absolutePath, filepath])
        let relativePath = self.getRelativePath(absolutePath)!
        
        var isDir = ObjCBool(false)
        fm.fileExistsAtPath(absolutePath, isDirectory: &isDir)
        return LocalFile(
          fileSource: self,
          relativePath: relativePath,
          isDirectory: isDir.boolValue
        )
      }
      dispatch_async(dispatch_get_main_queue()) {
        directory.childrenFiles = files
        callback(files);
      }
    } catch {
      print("\(error)")
    }
  }

  func createNewFile(relativePath: String) -> LocalFile? {
    let url = rootURL.URLByAppendingPathComponent(relativePath)
    let absolutePath = url.path!
    
    let fm = NSFileManager.defaultManager()
    if fm.fileExistsAtPath(absolutePath) {
      return nil
    }
    
    let directory = url.URLByDeletingLastPathComponent!.path!
    if !fm.fileExistsAtPath(directory) {
      do {
       try fm.createDirectoryAtPath(directory, withIntermediateDirectories: true, attributes: nil)
      } catch {
        print("\(error)")
        return nil
      }
    }
    
    if !fm.createFileAtPath(absolutePath, contents: nil, attributes: nil) {
      return nil
    }

    return LocalFile(fileSource: self, relativePath: relativePath, isDirectory: false)
  }
  
  func copy(file: File, localPath: String, copyCompleteHandler: () -> Void) -> Void {
    if file.fileSource !== self {
      return
    }
    let localFile = file as! LocalFile
    
    do {
      try NSFileManager.defaultManager().copyItemAtPath(localFile.absolutePath, toPath: localPath);
      dispatch_async(dispatch_get_main_queue()) {
        copyCompleteHandler()
      }
    } catch {
      print("\(error)")
    }
  }
}