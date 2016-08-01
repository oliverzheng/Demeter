//
//  RemoteFile.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/30/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Foundation

class RemoteFile: File {
  private(set) weak var fileSource: FileSource!
  private(set) var relativePath: String
  private(set) var isDirectory: Bool
  var childrenFiles: [File]?

  private(set) weak var localFile: File?
  
  init(
    fileSource: FileSource,
    relativePath: String,
    isDirectory: Bool,
    localFile: File? = nil
    ) {
    self.fileSource = fileSource
    self.relativePath = relativePath
    self.isDirectory = isDirectory
    self.localFile = localFile
  }
  
  var absolutePath: String {
    return fileSource.rootURL.URLByAppendingPathComponent(relativePath).path!
  }
  
  var filename: String {
    return (relativePath as NSString).lastPathComponent
  }
}