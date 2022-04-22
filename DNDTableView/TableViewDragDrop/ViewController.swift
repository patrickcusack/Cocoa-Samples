/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The primary view controller for this sample.
*/

import Cocoa

class DNDLogger : PCLogger {

    static let shared:DNDLogger! = DNDLogger()

    init() {
        let userpath = FileManager.default.homeDirectoryForCurrentUser.path
        let folder = (userpath as NSString).appendingPathComponent("/Library/Application Support/DNDLogger")
        super.init(folder:folder , name:"dndlogger")
    }
}

class ViewController: NSViewController {
   
	@IBOutlet weak var tableView: NSTableView!
    @objc dynamic var tableViewDelegate: DNDTableViewDelegate!
    
    /** This contentArray need @objc to make it key value compliant with this view controller,
        and so they are accessible and usable with Cocoa bindings.
    */
    @objc dynamic var contentArray: [PlaceholderObject] = [PlaceholderObject(firstName: "Ragnar", lastName: "Lothbrok", mobileNumber: "555-12347"),
                                                          PlaceholderObject(firstName: "Bjorn", lastName: "Lothbrok", mobileNumber: "555-34129"),
                                                          PlaceholderObject(firstName: "Harald", lastName: "Finehair", mobileNumber: "555-45128")]
    
	// MARK: - View life cycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
        
//        tableView.dataSource = self // Necessary for drag and drop.
        
        //This isn't working yet
        self.tableViewDelegate = DNDTableViewDelegate(tableView: tableView, contentArray: contentArray)
        
//        // Accept file promises from apps like Safari.
//        tableView.registerForDraggedTypes(
//            NSFilePromiseReceiver.readableDraggedTypes.map { NSPasteboard.PasteboardType($0) })
        
        tableView.registerForDraggedTypes([
            .fileURL, // Accept dragging of image file URLs from other apps.
            .rowDragType]) // Intra drag of row items numbers within the table.

        // Determine the kind of source drag originating from this app.
        // Note, if you want to allow your app to drag items to the Finder's trash can, add ".delete".
        tableView.setDraggingSourceOperationMask(.copy, forLocal: false)

	}
    

}
