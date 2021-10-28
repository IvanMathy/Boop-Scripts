//
//  ScriptManager.swift
//  Yup
//
//  Created by Ivan on 1/15/17.
//  Copyright © 2017 OKatBest. All rights reserved.
//

import Cocoa


class ScriptManager: NSObject {
    
    weak var delegate: ScriptDelegate?
    
    var scripts = [Script]()
    
    let currentAPIVersion = 1.0
    
    
    override init() {
        super.init()
        
        loadDefaultScripts()
        loadUserScripts()
    }
    

    
    /// Load built in scripts
    func loadDefaultScripts(){
        let urls = Bundle.module.urls(forResourcesWithExtension: "js", subdirectory: "scripts")
        
        urls?.forEach { script in
            loadScript(url: script, builtIn: true)
        }
    }
    
    
    /// Load user scripts
    func loadUserScripts(){
        
        do {
            
            guard let url = try delegate?.getScriptBaseURL() else {
                return
            }
            
            let urls = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .skipsHiddenFiles)
            
            urls.forEach { url in
                guard url.path.hasSuffix(".js") else {
                    return
                }
                loadScript(url: url, builtIn: false)
            }
            
        }
        catch let error {
            print(error)
            return
        }
    }
    
    /// Parses a script file
    private func loadScript(url: URL, builtIn: Bool){
        do{
            let script = try String(contentsOf: url)
            
            // This is inspired by the ISF file format by Vidvox
            // Thanks to them for the idea and their awesome work
            
            guard
                let openComment = script.range(of: "/**"),
                let closeComment = script.range(of: "**/")
                else {
                    throw NSError()
            }
            
            let meta = script[openComment.upperBound..<closeComment.lowerBound]
            
            let json = try JSONSerialization.jsonObject(with: meta.data(using: .utf8)!, options: .allowFragments) as! [String: Any]
            
            let scriptObject = Script(url: url, script: script, parameters: json, builtIn: builtIn, delegate: delegate)
            
            scripts.append(scriptObject)
            
            
        } catch {
            print("Unable to load ", url)
        }
    }
    
   
    
//    func runScript(_ script: Script, into editor: SyntaxTextView) {
//
//        let fullText = editor.text
//
//        lastScript = script
//
//        guard let ranges = editor.contentTextView.selectedRanges as? [NSRange], ranges.reduce(0, { $0 + $1.length }) > 0 else {
//
//            let insertPosition = (editor.contentTextView.selectedRanges.first as? NSRange)?.location
//            let result = runScript(script, fullText: fullText, insertIndex: insertPosition)
//            // No selection, run on full text
//
//            let unicodeSafeFullTextLength = editor.contentTextView.textStorage?.length ?? fullText.count
//            replaceText(ranges: [NSRange(location: 0, length: unicodeSafeFullTextLength)], values: [result], editor: editor)
//
//            return
//        }
//
//        // Fun fact: You can have multi selections! Which means we need to disable
//        // the ability to edit `fullText` while in selection mode, otherwise the
//        // some scripts may accidentally run multiple time over the full text.
//
//        let values = ranges.map {
//            range -> String in
//
//            let value = (fullText as NSString).substring(with: range)
//
//            return runScript(script, selection: value, fullText: fullText)
//
//        }
//
//        replaceText(ranges: ranges, values: values, editor: editor)
//
//
//    }
    
//    private func replaceText(ranges: [NSRange], values: [String], editor: SyntaxTextView) {
//
//
//        let textView = editor.contentTextView
//
//        // Since we have to replace each selection one by one, after each
//        // occurence the whole text shifts around a bit, and therefore the
//        // Ranges don't match their original position anymore. So we have
//        // to offset everything based on the previous replacements deltas.
//        // This is pretty straightforward because we know selections can't
//        // overlap, and we sort them so they are always in order.
//
//        var offset = 0
//        let pairs = zip(ranges, values)
//            .sorted{ $0.0.location < $1.0.location }
//            .map { (pair) -> (NSRange, String) in
//
//                let (range, value) = pair
//                let length = range.length
//                let newRange = NSRange(location: range.location + offset, length: length)
//
//                offset += value.count - length
//                return (newRange, value)
//        }
//
//
//        guard textView.shouldChangeText(inRanges: ranges as [NSValue], replacementStrings: values) else {
//            return
//        }
//
//        textView.textStorage?.beginEditing()
//
//        pairs.forEach {
//            (range, value) in
//            textView.textStorage?.replaceCharacters(in: range, with: value)
//        }
//
//
//        textView.textStorage?.endEditing()
//
//        textView.didChangeText()
//    }
    
//    func runScript(_ script: Script, selection: String? = nil, fullText: String, insertIndex: Int? = nil) -> String {
//        let scriptExecution = ScriptExecution(selection: selection, fullText: fullText, script: script, insertIndex: insertIndex)
//
//        self.statusView.setStatus(.normal)
//        script.run(with: scriptExecution)
//
//        return scriptExecution.text ?? ""
//    }
//
//    func runScriptAgain(editor: SyntaxTextView) {
//        guard let script = lastScript else {
//            NSSound.beep()
//            return
//        }
//
//        runScript(script, into: editor)
//    }
    
//    func reloadScripts() {
//        lastScript = nil
//        scripts.removeAll()
//        loadDefaultScripts()
//        loadUserScripts()
//
//        statusView.setStatus(.success("Reloaded Scripts"))
//    }
    
 
    
}
