//
//  fridge.swift
//  fridge
//
//  Created by Casey Miller on 2023-07-18.
//

import Foundation
import SwiftUI

class StackWindow: NSObject, NSApplicationDelegate {
    
    private var statusItem: NSStatusItem!
    private var menu: NSMenu!
    private var index = 0
    private var urls: [String: URL] = [:]
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        menu = NSMenu()
        
        if let button = statusItem.button {
            if #available(macOS 11.0, *) {
                let icon = NSImage(systemSymbolName: "refrigerator.fill", accessibilityDescription: "fridge")
                let config = NSImage.SymbolConfiguration(pointSize: 13, weight: .black)
                button.image = icon?.withSymbolConfiguration(config)
            } else { // previous macOS versions not supported
            }
        }
        setup()
    }
    
    func setup() {
        let addFileOption =  NSMenuItem(title: "Add File", action: #selector(addFileToStack), keyEquivalent: "a")
        menu.addItem(addFileOption)
        statusItem.menu = menu
    }
    
    @objc func addFileToStack() {
        let dialog = NSOpenPanel()
        dialog.title = "Choose a File to Add"
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsMultipleSelection = false
        dialog.canResolveUbiquitousConflicts = false
        dialog.canDownloadUbiquitousContents = true
        dialog.orderFrontRegardless()
        dialog.allowedContentTypes = [.pdf]
        
        var fileChoice: URL?
        if dialog.runModal() == NSApplication.ModalResponse.OK {
            fileChoice = dialog.url
        } else { // Cancel was pressed
            return
        }
        
        guard let url = fileChoice else {
            // Something went wrong
            return
        }
                
        let filePath = url.absoluteString
        if let match = filePath.firstMatch(of: /[^\/]+\.pdf$/) {
            let fileName = String(match.output)
            
            if urls.keys.contains(fileName) {
                return
            }
            
            let file = NSMenuItem(title: fileName, action: #selector(openFile(_:)), keyEquivalent: String(index+1))
            menu.insertItem(file, at: index)
            urls[file.title] = url
            index += 1
        }
        
        //        if urls.count == 4 {
        //            menu.items[menu.items.count-1].isHidden = true
        //        }
    }
    
    @objc func openFile(_ sender: NSMenuItem) {
        guard let url = urls[sender.title] else {
            return
        }
        NSWorkspace.shared.open(url)
    }
}
