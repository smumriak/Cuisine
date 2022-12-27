//
//  CuisineDemo.swift
//  CuisineDemo
//
//  Created by Serhii Mumriak on 22.09.2022
//

import Cuisine

public struct EmptyKey: PantryKey {
    public static var defaultValue: any StringProtocol = "I am default"
}

public extension Pantry {
    var empty: EmptyKey.Value {
        get {
            self[EmptyKey.self]
        }
        set {
            self[EmptyKey.self] = newValue
        }
    }
}

@main
public struct CuisineDemo {
    public private(set) var text = "Hello, World!"

    public static func main() async throws {
        let dish = Dish {
            if true {
                ChDir("hello") {
                    MultiFileGet {
                        if true {
                            "https://raw.githubusercontent.com/smumriak/AppKid/main/.gitlab-ci.yml"
                        }
                        "https://raw.githubusercontent.com/smumriak/AppKid/main/.gitlab-ci.yml"
                    }
                    GetFile("https://raw.githubusercontent.com/smumriak/AppKid/main/.gitlab-ci.yml").storeName(in: \.empty)
                    Print(format: "I am string format printing from keyPath. Printed value is %@ and I am happy about it!", \.empty)
                    ClearPantryItem(at: \.empty)
                    Print(\.empty)
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

        try await dish.cook()
    }
}
