import XCTest
@testable import BoopScripts


class TestScriptDelegate: ScriptDelegate {
    func onScriptError(message: String) {
        print("Error", message)
    }
    
    func onScriptInfo(message: String) {
        print("Info", message)
    }
    
    func getScriptBaseURL() throws -> URL? {
        Bundle.module.resourceURL?.appendingPathComponent("scripts", isDirectory: true)
    }
    
}


final class BoopScriptsTests: XCTestCase {
    
    
    
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        
        
        let manager = ScriptManager()
        
        let delegate = TestScriptDelegate()
        
        manager.delegate = delegate
        
        for script in manager.scripts {
            
            runTests(script: script)
            
        }
        
        //            let execution = ScriptExecution(selection: nil, fullText: "Test", script: manager.scripts.first!, insertIndex: 0)
        //
        //
        //            let out = manager.scripts.first?.run(with: execution)
        //
        //            Bundle.main
        
        
        
    }
    
    func runTests(script: Script) {
        
        let fileName = String(script.url.lastPathComponent.dropLast(3))
        
        print("├─ \(script.name ?? fileName)")
        
        guard let testDefinitionURL = Bundle.module.url(forResource: fileName, withExtension: "json", subdirectory: "tests") else {
            
            print("│  ├─ ⏺ No test provided, skipping. ")
            print("│")
            return
        }
            
            
            let jsonData = try! Data(contentsOf: testDefinitionURL)
            let testDefinitions = try! JSONDecoder().decode([TestDefinition].self, from: jsonData)
            
            
            var success = 0
            var failure = 0
            
            for test in testDefinitions {
                let execution = ScriptExecution(selection: nil, fullText: test.input.fullText, script: script, insertIndex: 0)
                
                script.run(with: execution)
                
                if(execution.fullText == test.output.fullText) {
                    print("│  ├─ ✅ \(test.name)")
                    success += 1
                } else {
                    print("│  ├─ 🛑 \(test.name)")
                    
                    print("│  │   Expected output:\n\(test.output.fullText) \nGot:\n\(execution.fullText ?? "No Output")".components(separatedBy: "\n").joined(separator: "\n│  │   "))
                    
                    failure += 1
                }
            }
            
            print("│ \(testDefinitions.count) tests - \(success) succesful, \(failure) failures")
        
            print("│")
            
        
    }
}
