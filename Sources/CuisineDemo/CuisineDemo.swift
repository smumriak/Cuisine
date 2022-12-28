//
//  CuisineDemo.swift
//  CuisineDemo
//
//  Created by Serhii Mumriak on 22.09.2022
//

import Cuisine
import CuisineArgumentParser
import ArgumentParser

@main
struct CuisineDemo: CuisineParsableCommand {
    var pantry: Pantry = Pantry()

    @Argument(help: "The phrase to repeat.")
    var phrase: String = "Sample Phrase"

    var body: some Recipe {
        if true {
            ChDir("hello") {
                Print(phrase)
                MultiFileGet {
                    if true {
                        "https://raw.githubusercontent.com/smumriak/AppKid/main/.gitlab-ci.yml"
                    }
                    "https://raw.githubusercontent.com/smumriak/AppKid/main/.gitlab-ci.yml"
                }
                GetFile("https://raw.githubusercontent.com/smumriak/AppKid/main/.gitlab-ci.yml").storeName(in: \.sampleString)
                Print(format: "I am string format printing from keyPath. Printed value is %@ and I am happy about it!", \.sampleString)
                ClearPantryItem(at: \.sampleString)
                Print(\.sampleString)
                Map(\.sampleString, output: \.sampleString) { _ in
                    if pantry.sampleString == "" {
                    }
                    return "Remapping values here"
                }
                Print(\.sampleString)
                Map(\.sampleString, output: \.sampleString) { _ in
                    "Empty"
                }
                If({ String($0.sampleString) == "Empty" }) {
                    print("Printing inside if!")
                }
            }
        }
        Group(blocking: false) {
            Group(blocking: false) {
                Print {
                    "Print recipe 1: first line"
                    "Print recipe 1: second line"
                }

                Print {
                    if true {
                        "Print recipe 2: body of if-true"
                    }
                }
                Run("echo") {
                    "Hello, Shell!"
                    "This is a multi-string echo command!"
                }
            }
            Print {
                "Last print recipe"
            }
            Script {
                """
                #!/bin/bash
                echo I can run scripts as is.
                for WORD in one two three four five six seven eight
                do
                    echo $WORD
                done
                exit 0
                """
            }
        }

        Concurrent {
            Print("Concurrent print 1")
            Print("Concurrent print 2")
            Print("Concurrent print 3")
            Print("Concurrent print 4")
        }
    }
}

public struct SampleStringKey: PantryKey {
    public static var defaultValue: String = "Sample String"
}

public extension Pantry {
    var sampleString: SampleStringKey.Value {
        get {
            self[SampleStringKey.self]
        }
        set {
            self[SampleStringKey.self] = newValue
        }
    }
}
