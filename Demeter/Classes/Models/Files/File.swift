//
//  File.swift
//  Demeter
//
//  Created by Oliver Zheng on 7/30/16.
//  Copyright © 2016 Oliver Zheng. All rights reserved.
//

import Foundation

protocol File: class {
  var fileSource: FileSource! { get }
  var relativePath: String { get }
  var isDirectory: Bool { get }
  var childrenFiles: [File]? { get set }
}

extension File {
  
  var filename: String {
    return (relativePath as NSString).lastPathComponent
  }

  var absolutePath: String {
    return fileSource.rootURL.URLByAppendingPathComponent(relativePath).path!
  }
}