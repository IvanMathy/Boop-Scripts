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


final class BoopScriptTests: XCTestCase {
    
    var output = ""
    
    func print(_ value: String) {
        output = output + "\n" + value
    }
    
    override class var defaultTestSuite: XCTestSuite {
        let testClass = self as XCTestCase.Type
        let testSuite = XCTestSuite(name: "Boop Scripts")
        
        let manager = ScriptManager()
        
        let delegate = TestScriptDelegate()
        
        manager.delegate = delegate
        
        
        for script in manager.scripts {
            
//            runTests(script: script)
            
            let testCase = BoopScriptTests(selector: #selector(testScript))
                
            testCase.test = script.url.absoluteString
              testCase.script = script
                
              testSuite.addTest(testCase)
            
            
        }
        
        
        return testSuite
      }
    
    
    var script: Script!
    var test: String?
    
    var fileName: String {
        get { return String(script.url.lastPathComponent.dropLast(3)) }
    }
    
    public override var name: String {
        get { return script.name ?? fileName }
    }
    
    override func tearDown() {
        Swift.print(output)
    }
    
    func testScript() {
        
        self.print("├─ \(script.name ?? fileName)")
        
        guard let testDefinitionURL = Bundle.module.url(forResource: fileName, withExtension: "json", subdirectory: "tests") else {
            
            self.print("│  ├─ ⏺ No test provided, skipping. ")
            self.print("│")
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
                    self.print("│  ├─ ✅ \(test.name)")
                    success += 1
                } else {
                    self.print("│  ├─ 🛑 \(test.name)")
                    
                    self.print("│  │   Expected output:\n\(test.output.fullText) \nGot:\n\(execution.fullText ?? "No Output")".components(separatedBy: "\n").joined(separator: "\n│  │   "))
                    
                    failure += 1
                }
                
                XCTAssertEqual(execution.fullText, test.output.fullText, test.name)
                
                
            }
            
        self.print("│ \(testDefinitions.count) tests - \(success) succesful, \(failure) failed")
        
        self.print("│")
                
        
        
    }
}
