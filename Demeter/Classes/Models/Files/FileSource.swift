//
//  FileSource.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/29/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Foundation

protocol FileSource: class {

  var isAvailable: Bool { get }
  
  var rootURL: NSURL { get }
  var rootDirectoryFile: File { get }
  
  func listFilesInDirectory(directory: File, callback: ([File]) -> Void) -> Void
  
  func copy(file: File, localPath: String, copyCompleteHandler: () -> Void) -> Void
}

extension FileSource {

  func getRelativePath(absolutePath: String) -> String? {
    if !absolutePath.hasPrefix(rootURL.path!) {
      return nil
    }
    
    let index = absolutePath.startIndex.advancedBy(rootURL.path!.characters.count)
    return absolutePath.substringFromIndex(index)
  }

}