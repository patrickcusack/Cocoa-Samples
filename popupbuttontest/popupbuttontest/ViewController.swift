//
//  ViewController.swift
//  popupbuttontest
//
//  Created by Patrick Cusack on 1/20/22.
//

import Cocoa

func randomNameString(length: Int = 10)->String{
    
    enum s {
        static let c = Array("abcdefghjklmnopqrstuvwxyz123457890")
        static let k = UInt32(c.count)
    }
    
    var result = [Character](repeating: "-", count: length)
    
    for i in 0..<length {
        let r = Int(arc4random_uniform(s.k))
        result[i] = s.c[r]
    }
    
    return String(result)
}

class Preset : NSObject {
    @objc dynamic var name : String = "New Preset"
    @objc dynamic var layers : [String] = [String]()
    @objc dynamic var uuid : String = UUID().uuidString
    
    @objc dynamic var changeables : [String] = [String]()
    
    init(name : String) {
      self.name = name
    }
    
}

class ViewController: NSViewController {

    
    @IBOutlet var presetsController: NSArrayController!
    @IBOutlet weak var popUpButton: NSPopUpButton!
    @IBOutlet weak var textField: NSTextField!
    @IBOutlet var presetController: NSObjectController!
    
    @objc dynamic var presets : [Preset]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presets = [Preset]()
        
        self.presets.append(Preset(name:"Patrick"))
        self.presets.append(Preset(name:"Lisa"))
        self.presets.append(Preset(name:"Ethan"))
        self.presets.append(Preset(name:"Connor"))
        self.presets.append(Preset(name:"Clara"))
        
        print(presetController.exposedBindings)
        print(presetsController.exposedBindings)
        print(popUpButton.exposedBindings)
        
        popUpButton.bind(NSBindingName(rawValue: "selectedIndex"),
                         to: presetsController as Any,
                         withKeyPath: "selectionIndex", options: nil)
        
        textField.delegate = self
    }
    
    override func viewDidAppear() {
        super.viewDidAppear()
        self.view.window?.makeFirstResponder(nil)
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func handlePopUp(_ sender: Any) {
        print("\(sender)")
        if let popUp  = sender as? NSPopUpButton {
            print(popUp.title)
            
            let selected = self.presetsController.selectedObjects
            if let selected = selected {
                if selected.count > 0 {
                    let preset = selected[0]
                    var mArray = [String]()
                    for _ in 0..<10 {
                        mArray.append(randomNameString())
                    }
                    (preset as! Preset).changeables = mArray
                }
            }

        }
    }
    
}

extension ViewController: NSTextFieldDelegate, NSControlTextEditingDelegate {
    
    func control(_ control: NSControl, textShouldEndEditing fieldEditor: NSText) -> Bool {
        let editedname = fieldEditor.string
        let currentPresetName = self.popUpButton.title
    
        if self.popUpButton.itemTitles.firstIndex(of: editedname) != nil
            && editedname != currentPresetName{
            return false
        }
        
        return true
    }
    
}
