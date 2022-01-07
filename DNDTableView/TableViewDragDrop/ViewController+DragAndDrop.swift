/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Primary view controller table view data source for handling drag and drop.
*/

import Cocoa
import UniformTypeIdentifiers // for UTType

// MARK: NSTableViewDataSource

/**
 
        pasteboardWriterForRow
            draggingSession start
                validateDrop
                    dragSourceIsFromOurTable
                validateDrop: move
                validateDrop
                validateDrop: ontop, bailing
                validateDrop
                    dragSourceIsFromOurTable
                validateDrop: move
                validateDrop
                    dragSourceIsFromOurTable
                validateDrop: move
            acceptDrop
                dragSourceIsFromOurTable
                dropInternalPhotos
                    moveObjectsFromIndexes
                    rowsMovedDownward
            draggingSession endedAt
 
 */

extension NSPasteboard.PasteboardType {
    static let rowDragType = NSPasteboard.PasteboardType("com.aaws.tvdraganddrop")
}

extension ViewController: NSTableViewDataSource {
    
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
        tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
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
          
            let object = contentArray[removeIndex]
            contentArray.remove(at: removeIndex)
            contentArray.insert(object, at: insertIndex)
          
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
    
//    /** Insert the given url as a PhotoItem to the target row number.
//        Return false if loading image fails and the URL and is not inserted.
//    */
//
//    /*
//    func insertURL(_ url: URL, toRow: Int) -> Bool {
//        DNDLogger.shared.debug(str: "insertURL")
//        var urlInserted = false
//        do {
//            let resourceValues = try url.resourceValues(forKeys: Set([.typeIdentifierKey]))
//
//            var urlTypeConformsToImage = false
//
//            if let typeIdentifier = resourceValues.typeIdentifier {
//                // The file URL has a type identifier, use it to create it's UTType to check for conformity.
//                if #available(macOS 11.0, *) {
//                    if let fileUTType = UTType(typeIdentifier) {
//                        urlTypeConformsToImage = fileUTType.conforms(to: UTType.image)
//                    }
//                } else {
//                    if UTTypeConformsTo(typeIdentifier as CFString, kUTTypeImage) {
//                        urlTypeConformsToImage = true
//                    }
//                }
//
//            } else {
//                // The file URL does not have a type identifier, use the extension to determine if it's an image type.
//                let urlExtension = url.pathExtension
//                if #available(macOS 11.0, *) {
//                    if let type = UTType(filenameExtension: urlExtension) {
//                        if type.conforms(to: UTType.image) {
//                            urlTypeConformsToImage = true
//                        }
//                    }
//                } else {
//                    let typeIdentifier =
//                        UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, urlExtension as CFString, nil)
//                    if UTTypeConformsTo(typeIdentifier!.takeRetainedValue() as CFString, kUTTypeImage) {
//                        urlTypeConformsToImage = true
//                    }
//                }
//            }
//
//            if urlTypeConformsToImage {
//                // URL is an image file, add it to the table view.
//                let photoItem = PhotoItem(url: url)
//
//                // Set up ourselves to be notified when the photo's thumbnail is ready.
//                photoItem.thumbnailDelegate = self
//
//                // Start to load the image.
//                photoItem.loadImage()
//
//                self.contentArray.insert(photoItem, at: toRow)
//                urlInserted = true
//            }
//        } catch {
//            Swift.debugPrint("Can't obtain the type identifier for \(url): \(error)")
//        }
//        return urlInserted
//    }
//     */
//
//    /** Given an NSDraggingInfo from an incoming drag, handle any and all promise drags.
//        Note that promise drags can come from any app that offers it (i.e. Safari or Photos).
//    */
//
//    func handlePromisedDrops(draggingInfo: NSDraggingInfo, toRow: Int) -> Bool {
//        DNDLogger.shared.debug(str: "handlePromisedDrops")
//        var handled = false
//        if let promises = draggingInfo.draggingPasteboard.readObjects(forClasses: [NSFilePromiseReceiver.self], options: nil) {
//            if !promises.isEmpty {
//                // We have incoming drag item(s) that are file promises.
//
//                // At the start of insertion(s), clear the current table view selection.
//                tableView.deselectAll(self)
//
//                for promise in promises {
//                    if let promiseReceiver = promise as? NSFilePromiseReceiver {
//                        // Show the progress indicator as we start receiving this promised file.
//                        progressIndicator.isHidden = false
//                        progressIndicator.startAnimation(self)
//
//                        // Ask our file promise receiver to fulfull on their promise.
//                        promiseReceiver.receivePromisedFiles(atDestination: destinationURL,
//                                                             options: [:],
//                                                             operationQueue: filePromiseQueue) { (fileURL, error) in
//                            /** Finished copying the promised file.
//                                Back on the main thread, insert the newly created image file into the table view.
//                            */
//                            OperationQueue.main.addOperation {
//                                if error != nil {
//                                    self.reportURLError(fileURL, error: error!)
//                                } else {
//                                    _ = self.insertURL(fileURL, toRow: toRow)
//
//                                    /** Select the newly inserted photo,
//                                        extend the selection so to accumulate multiple selected photos.
//                                    */
//                                    let indexSet = IndexSet(integer: toRow)
//                                    self.tableView.selectRowIndexes(indexSet, byExtendingSelection: true)
//                                }
//                                // Stop the progress indicator as we are done receiving this promised file.
//                                self.progressIndicator.isHidden = true
//                                self.progressIndicator.stopAnimation(self)
//                            }
//                        }
//                    }
//                }
//                handled = true
//            }
//        }
//        return handled
//    }
//
//    /*
//    // Drop the internal dragged photos in this table view to the target row.
//    func handleExternalDrop(_ tableView: NSTableView, draggingInfo: NSDraggingInfo, toRow: Int) {
//        DNDLogger.shared.debug(str: "dropExternalPhotos")
//
//        // If possible, first handle the incoming dragged photos as file promises.
//        if handlePromisedDrops(draggingInfo: draggingInfo, toRow: toRow) {
//            // Successfully processed the dragged items that were promised to us.
//        } else {
//            // Incoming drag was not propmised, so move in all the outside dragged items as URLs.
//            var foundNonImageFiles = false
//            var numItemsInserted = 0
//            draggingInfo.enumerateDraggingItems(
//                options: NSDraggingItemEnumerationOptions.concurrent,
//                for: tableView,
//                classes: [NSPasteboardItem.self],
//                searchOptions: [:],
//                using: {(draggingItem, idx, stop) in
//                    if let pasteboardItem = draggingItem.item as? NSPasteboardItem {
//                        // Are we being passed a file URL as the drag type?
//                        if  let itemType = pasteboardItem.availableType(from: [.fileURL]),
//                            let filePath = pasteboardItem.string(forType: itemType),
//                            let url = URL(string: filePath) {
//                                if self.insertURL(url, toRow: toRow) {
//                                    numItemsInserted += 1
//                                } else {
//                                    foundNonImageFiles = true
//                            }
//                        }
//                    }
//                })
//
//            // Select the newly inserted photo items.
//            let selectionRange = toRow..<toRow + numItemsInserted
//            let indexSet = IndexSet(integersIn: selectionRange)
//            tableView.selectRowIndexes(indexSet, byExtendingSelection: false)
//
//            // If any of the dragged URLs were not image files, alert the user.
//            if foundNonImageFiles {
//                let alert = NSAlert()
//                alert.messageText = NSLocalizedString("CannotImportTitle", comment: "")
//                alert.informativeText = NSLocalizedString("CannotImportMessage", comment: "")
//                alert.addButton(withTitle: NSLocalizedString("OKTitle", comment: ""))
//                alert.alertStyle = .warning
//                alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
//            }
//        }
//    }
//    */
//
//    // Reports the error and related URL, generated from the NSFilePromiseReceiver operation.
//    func reportURLError(_ url: URL, error: Error) {
//        DNDLogger.shared.debug(str: "reportURLError")
//        let alert = NSAlert()
//        alert.messageText = NSLocalizedString("ErrorTitle", comment: "")
//        alert.informativeText = String(format: NSLocalizedString("ErrorMessage", comment: ""), url.lastPathComponent, error.localizedDescription)
//        alert.addButton(withTitle: NSLocalizedString("OKTitle", comment: ""))
//        alert.alertStyle = .warning
//        alert.beginSheetModal(for: self.view.window!, completionHandler: nil)
//    }
//
//// MARK: - NSFilePromiseProviderDelegate
//
//extension ViewController: NSFilePromiseProviderDelegate {
//
//    /** This function is called at drop time to provide the title of the file being dropped.
//        This sample uses a hard-coded string for simplicity, but depending on your use case, you should take the fileType parameter into account.
//    */
//    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider, fileNameForType fileType: String) -> String {
//        DNDLogger.shared.debug(str: "filePromiseProvider")
//        // Return the photoItem's URL file name.
//        let photoItem = photoFromFilePromiserProvider(filePromiseProvider: filePromiseProvider)
//        return (photoItem?.fileURL.lastPathComponent)!
//    }
//
//    func filePromiseProvider(_ filePromiseProvider: NSFilePromiseProvider,
//                             writePromiseTo url: URL,
//                             completionHandler: @escaping (Error?) -> Void) {
//        DNDLogger.shared.debug(str: "writePromiseTo")
//        do {
//            if let photoItem = photoFromFilePromiserProvider(filePromiseProvider: filePromiseProvider) {
//                /** Copy the file to the location provided to us. We always do a copy, not a move.
//                    It's important you call the completion handler.
//                */
//                try FileManager.default.copyItem(at: photoItem.fileURL, to: url)
//            }
//            completionHandler(nil)
//        } catch let error {
//            OperationQueue.main.addOperation {
//                self.presentError(error, modalFor: self.view.window!,
//                                  delegate: nil, didPresent: nil, contextInfo: nil)
//            }
//            completionHandler(error)
//        }
//    }
//
//    /** You should provide a non main operation queue (e.g. one you create) via this function.
//        This way you don't stall the main thread while writing the promise file.
//    */
//
//    func operationQueue(for filePromiseProvider: NSFilePromiseProvider) -> OperationQueue {
//        DNDLogger.shared.debug(str: "operationQueue")
//        return filePromiseQueue
//    }
//
//    // Utility function to return a PhotoItem object from the NSFilePromiseProvider.
//    func photoFromFilePromiserProvider(filePromiseProvider: NSFilePromiseProvider) -> PhotoItem? {
//        DNDLogger.shared.debug(str: "photoFromFilePromiserProvider")
//        var returnPhoto: PhotoItem?
//        if  let userInfo = filePromiseProvider.userInfo as? [String: Any],
//            let row = userInfo[FilePromiseProvider.UserInfoKeys.rowNumberKey] as? Int {
//                returnPhoto = contentArray[row]
//        }
//        return returnPhoto
//    }
//
