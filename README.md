# Cuisine

Declarative DSL to automate deployment of stuff in Swift.


``` swift
import Cuisine
import CusineArgumentParser

let vscodeSettings: String = ...
let vscodeTasks: String = ...
let vscodeLaunch: String = ...
let gitignore: String = ...
let swiftformat: String = ...
enum PackageType {...}

@main
struct SwiftBootstrap: CuisineParsableCommand {
  @Argument var name: String
  @Option var type: PackageType = .executable
  @Option var swiftLocation: String = "/opt/swift"
  @Option var addGitIgnore: Bool = true
  @Option var addSwiftFormat: Bool = true
  
  var body: some Recipe {
    ChDir(name) {
      ChDir(".vscode", blocking: false) {
        Concurrent {
          WriteToFile("settings.json", format: vscodeSettings, swiftLocation)
          WriteToFile("tasks.json") { vscodeTasks }
          WriteToFile("launch.json", format: vscodeLaunch, name.repeat(3))
          WriteToFile("extensions.json") { extensions }
        }
      }
      Concurrent {
        if addGitIgnore {
          WriteToFile(".gitignore") { gitignore }
        }
        if addSwiftFormat {
          WriteToFile(".swiftformat") { swiftformat }
        }
        Run("swift package init") {
          "--type \(type)"
          "--name \(name)"
        }
      }
    }
  }
}
```