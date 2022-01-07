//
//  PCLogger.swift
//  DMI-Trix
//
//  Created by Patrick Cusack on 10/21/21.
//

import Foundation

class PCLogger {
    
    var fh : FileHandle?
    
    init(folder:String, name:String) {

        let logpath = (folder as NSString).appendingPathComponent(name + ".txt")
        
        var isDir = ObjCBool(false)
        if !FileManager.default.fileExists(atPath: folder, isDirectory: &isDir) {
            
            do {
                try FileManager.default.createDirectory(atPath: folder,
                                                        withIntermediateDirectories: false,
                                                        attributes: nil)
            } catch {
                print(error)
            }
            
            if !FileManager.default.fileExists(atPath: logpath){
                FileManager.default.createFile(atPath: logpath,
                                               contents: nil,
                                               attributes: nil)
            }
            
            if let handle = FileHandle.init(forWritingAtPath: logpath) {
                self.fh = handle
                self.fh?.seekToEndOfFile()
            }
            
        } else {
            
            if !FileManager.default.fileExists(atPath: logpath){
                FileManager.default.createFile(atPath: logpath,
                                               contents: nil,
                                               attributes: nil)
            }
            
            if let handle = FileHandle.init(forWritingAtPath: logpath) {
                self.fh = handle
                self.fh?.seekToEndOfFile()
            }
            
        }
        
    }

    func debug(str:String){
        if let handle = self.fh,
           let data = (Date().getFormattedDate(format: "HH:mm:ss MM-dd-yy") + ": " + str + "\n").data(using: String.Encoding.utf8){
            handle.write(data)
        }
    }
    
}
