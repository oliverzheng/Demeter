//
//  LocalFile.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/30/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Foundation

class LocalFile: File {
  private(set) weak var fileSource: FileSource!
  private(set) var relativePath: String
  private(set) var isDirectory: Bool
  var childrenFiles: [File]?
  
  init(
    fileSource: LocalFileSource,
    relativePath: String,
    isDirectory: Bool
  ) {
    self.fileSource = fileSource
    self.relativePath = relativePath
    self.isDirectory = isDirectory
  }
  
  var isAvailable: Bool {
    let fm = NSFileManager.defaultManager()
    return fm.fileExistsAtPath(self.absolutePath);
  }
  
  var absolutePath: String {
    return fileSource.rootURL.URLByAppendingPathComponent(relativePath).path!
  }
  
  var filename: String {
    return (relativePath as NSString).lastPathComponent
  }
}