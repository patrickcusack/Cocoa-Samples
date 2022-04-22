//
//  DNDTableViewDelegate.swift
//  TableViewDragDrop
//
//  Created by Patrick Cusack on 1/8/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Cocoa
import UniformTypeIdentifiers // for UTType

class DNDTableViewDelegate: NSObject, NSTableViewDataSource {
    
    var tableView: NSTableView!
//    var contentArray: [Any]!
    
    @objc dynamic var contentArray: [PlaceholderObject] = [PlaceholderObject(firstName: "Ragnarok", lastName: "Lothbrok", mobileNumber: "555-12347"),
                                                          PlaceholderObject(firstName: "Bjorn", lastName: "Lothbrok", mobileNumber: "555-34129"),
                                                          PlaceholderObject(firstName: "Harald", lastName: "Finehair", mobileNumber: "555-45128")]
    
    init(tableView: NSTableView, contentArray: [Any]) {
        super.init()
        
        self.tableView = tableView
//        self.contentArray = contentArray
        self.tableView.dataSource = self
    }
    
    /** Dragging Source Support - Optional. Implement this method to know when the dragging session is about to begin and to potentially modify the dragging session.'rowIndexes' are the row indexes being dragged, excluding rows that were not dragged due to tableView:pasteboardWriterForRow: returning nil. The order will directly match the pasteboard writer array used to begin the dragging session with [NSView beginDraggingSessionWithItems:event:source]. Hence, the order is deterministic, and can be used in -tableView:acceptDrop:row:dropOperation: when enumerating the NSDraggingInfo's pasteboard classes.
     */
    
    func tableView(_ tableView: NSTableView, draggingSession session: NSDraggingSession, willBeginAt screenPoint: NSPoint, forRowIndexes rowIndexes: IndexSet) {
        DNDLogger.shared.debug(str: "draggingSession start")
    }
    
    /** Implement this function to know when the dragging session has ended.
        This delegate function can be used to know when the dragging source operation ended at a specific location,
        such as the trash (by checking for an operation of NSDragOperationDelete).
    */
    
    /** Dragging Source Support - Optional. Implement this method to know when the dragging session has ended. This delegate method can be used to know when the dragging source operation ended at a specific location, such as the trash (by checking for an operation of NSDragOperationDelete).
     */
    
    func tableView(_ tableView: NSTableView,
                   draggingSession session: NSDraggingSession,
                   endedAt screenPoint: NSPoint,
                   operation: NSDragOperation) {
        DNDLogger.shared.debug(str: "draggingSession endedAt")
        if operation == .delete, let items = session.draggingPasteboard.pasteboardItems {
            // User dragged the photo to the Finder's trash.
            for pasteboardItem in items {
                Swift.debugPrint(pasteboardItem)
            }
        }
    }
    
    // The mouse was released over a table view that previously decided to allow a drop.
    func tableView(_ tableView: NSTableView,
                   acceptDrop info: NSDraggingInfo,
                   row: Int,
                   dropOperation: NSTableView.DropOperation) -> Bool {
        DNDLogger.shared.debug(str: "acceptDrop")
        // Check where the dragged items are coming.
        if dragSourceIsFromOurTable(draggingInfo: info) {
            /** Drag source came from our own table view.
                Move each dragged photo item to their new place.
            */
            handleInternalDrop(tableView, draggingInfo: info, toRow: row)
        } else {
            /** The drop source is from another app (Finder, Mail, Safari, etc.) and there may be more than one file.
                Drop each dragged image file to their new place.
            */
            //handleExternalDrop(tableView, draggingInfo: info, toRow: row)
        }
        return true
    }
    
    /** Dragging Source Support - Required for multi-image dragging. Implement this method to allow the table to be an NSDraggingSource that supports multiple item dragging. Return a custom object that implements NSPasteboardWriting (or simply use NSPasteboardItem). If this method is implemented, then tableView:writeRowsWithIndexes:toPasteboard: will not be called.
     */
    
    // A PhotoItem in our table is being dragged for this given row, provide the pasteboard writer for this item.
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        DNDLogger.shared.debug(str: "Begin - pasteboardWriterForRow")
        
        let item:NSPasteboardItem = NSPasteboardItem()
        item.setPropertyList(row, forType: .rowDragType)
        return item
    }
        
    /** Dragging Destination Support - This method is used by NSTableView to determine a valid drop target. Based on the mouse position, the table view will suggest a proposed drop 'row' and 'dropOperation'. This method must return a value that indicates which NSDragOperation the data source will perform. The data source may "re-target" a drop, if desired, by calling setDropRow:dropOperation: and returning something other than NSDragOperationNone. One may choose to re-target for various reasons (eg. for better visual feedback when inserting into a sorted position).
    */
    
    // This function is called when a drag is moved over the table view and before it has been dropped.
    func tableView(_ tableView: NSTableView,
                   validateDrop info: NSDraggingInfo,
                   proposedRow row: Int,
                   proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {
        DNDLogger.shared.debug(str: "validateDrop")
        var dragOperation: NSDragOperation = []
        
        // We only support dropping items between rows (not on top of a row).
        guard dropOperation != .on else {
            DNDLogger.shared.debug(str: "validateDrop: ontop, bailing")
            return dragOperation
        }

        if dragSourceIsFromOurTable(draggingInfo: info) {
            // Drag source came from our own table view.
            dragOperation = [.move]
            DNDLogger.shared.debug(str: "validateDrop: move")
        } else {
            
            /*
            let pasteboard = info.draggingPasteboard
            guard let items = pasteboard.pasteboardItems else { return dragOperation }
            for item in items {
                var type: NSPasteboard.PasteboardType
                if #available(macOS 11.0, *) {
                    type = NSPasteboard.PasteboardType(UTType.image.identifier)
                } else {
                    type = (kUTTypeImage as NSPasteboard.PasteboardType)
                }
                if item.availableType(from: [type]) != nil {
                    // Drag source is coming from another app as a promised image file (for example from Photos app).
                    dragOperation = [.copy]
                    DNDLogger.shared.debug(str: "validateDrop: copy from outside")
                }
            }
             
             // Drag source came from another app.
             //
             // Search through the array of NSPasteboardItems.
             // TO BE HANDLED
             
             */
        }
        
        // This is not in use
        // Has a drop operation been determined yet?
        if dragOperation == [] {
            // Look for possible URLs we can consume.
            var acceptedTypes: [String]
            if #available(macOS 11.0, *) {
                acceptedTypes = [UTType.image.identifier]
            } else {
                acceptedTypes = [kUTTypeImage as String]
            }

            let options = [NSPasteboard.ReadingOptionKey.urlReadingFileURLsOnly: true,
                           NSPasteboard.ReadingOptionKey.urlReadingContentsConformToTypes: acceptedTypes]
                as [NSPasteboard.ReadingOptionKey: Any]
            let pasteboard = info.draggingPasteboard
            // Look only for image urls.
            if let urls = pasteboard.readObjects(forClasses: [NSURL.self], options: options) {
                if !urls.isEmpty {
                    /** One or more of the URLs in this drag is image file.
                        We allow for this; a user may be able to drag in a mix of files, any one of them being an image file.
                    */
                    dragOperation = [.copy]
                }
            }
        }

        return dragOperation
    }
    
    func dragSourceIsFromOurTable(draggingInfo: NSDraggingInfo) -> Bool {
        DNDLogger.shared.debug(str: "dragSourceIsFromOurTable")
        if let draggingSource = draggingInfo.draggingSource as? NSTableView, draggingSource == tableView {
            return true
        } else {
            return false
        }
    }
    
    // Drop the internal dragged photos in this table view to the target row number.
    func handleInternalDrop(_ tableView: NSTableView, draggingInfo: NSDraggingInfo, toRow: Int) {
        DNDLogger.shared.debug(str: "dropInternalPhotos")
        var indexesToMove = IndexSet()
        
        draggingInfo.enumerateDraggingItems(
            options: NSDraggingItemEnumerationOptions.concurrent,
            for: tableView,
            classes: [NSPasteboardItem.self],
            searchOptions: [:],
            using: {(draggingItem, idx, stop) in
                if  let pasteboardItem = draggingItem.item as? NSPasteboardItem,
                    let photoRow = pasteboardItem.propertyList(forType: .rowDragType) as? Int {
                        indexesToMove.insert(photoRow)
                    }
            })
                
        // Move/drop the photos in their correct place using their indexes.
        moveObjectsFromIndexes(indexesToMove, toIndex: toRow)
        
        // Set the selected rows to those that were just moved.
        let rowsMovedDown = rowsMovedDownward(toRow, indexSet: indexesToMove)
        let selectionRange = toRow - rowsMovedDown..<toRow - rowsMovedDown + indexesToMove.count
        let indexSet = IndexSet(integersIn: selectionRange)
        self.tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
    }
    
    // MARK: - Table Row Movement Utilities

    // Move the set of objects within the indexSet to the 'toIndex' row number.
    func moveObjectsFromIndexes(_ indexSet: IndexSet, toIndex: Int) {
        DNDLogger.shared.debug(str: "moveObjectsFromIndexes")
        var insertIndex = toIndex
        var currentIndex = indexSet.last
        var aboveInsertCount = 0
        var removeIndex = 0
      
        while currentIndex != nil {
            if currentIndex! >= toIndex {
                removeIndex = currentIndex! + aboveInsertCount
                aboveInsertCount += 1
            } else {
                removeIndex = currentIndex!
                insertIndex -= 1
            }
            
            for obj in contentArray {
                if let place = obj as? PlaceholderObject {
                    print("Before \(place.firstName)")
                }
            }
            
            let object = contentArray[removeIndex]
            contentArray.remove(at: removeIndex)
            contentArray.insert(object, at: insertIndex)
            
            for obj in contentArray {
                if let place = obj as? PlaceholderObject {
                    print("After \(place.firstName)")
                }
            }
          
            currentIndex = indexSet.integerLessThan(currentIndex!)
        }
    }
    
    // Returns the number of rows dragged in a downward direction within the table view.
    func rowsMovedDownward(_ row: Int, indexSet: IndexSet) -> Int {
        DNDLogger.shared.debug(str: "rowsMovedDownward")
        var rowsMovedDownward = 0
        var currentIndex = indexSet.first
        while currentIndex != nil {
            if currentIndex! < row {
                rowsMovedDownward += 1
            }
            currentIndex = indexSet.integerGreaterThan(currentIndex!)
        }
        return rowsMovedDownward
    }
    
}

