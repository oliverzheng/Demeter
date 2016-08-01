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
  var absolutePath: String { get }
  var filename: String { get }
  var isDirectory: Bool { get }
  var childrenFiles: [File]? { get set }
}