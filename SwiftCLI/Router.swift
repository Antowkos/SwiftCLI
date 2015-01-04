//
//  Router.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/11/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

enum RouterResult {
    case Success(Command, [String], String)
    case Failure
}

class Router {
    
    private let commands: [Command]
    private let arguments: [String]
    private var defaultCommand: Command
    
    init(commands: [Command], arguments: [String], defaultCommand: Command) {
        self.commands = commands
        self.arguments = arguments
        self.defaultCommand = defaultCommand
    }
    
    func route() -> RouterResult {
        if arguments.count == 1 { // e.g. "bundle"
            return .Success(defaultCommand, [], "")
        }
        
        let commandString = arguments[1]

        let (command, commandName, remainingArgumentsIndex) = findCommand(commandString)
        
        if command == nil {
            return .Failure
        }
        
        let remainingArgs = Array(arguments[remainingArgumentsIndex..<arguments.count])
        return .Success(command!, remainingArgs, commandName)
    }
    
    // MARK: - Privates
    
    private func findCommand(commandString: String) -> (command: Command?, commandName: String, remainingArgumentsIndex: Int) {
        var command: Command?
        var cmdName: String = commandString
        var argumentsStartingIndex = 2
        
        if commandString.hasPrefix("-") {
            command = findCommandWithShortcut(commandString)
            
            // If no command with shorcut found, pass the -arg as a flag to the default command
            if command == nil {
                command = defaultCommand
                argumentsStartingIndex = 1
                cmdName = ""
            }
        } else {
            command = findCommandWithName(commandString)
        }
        
        return (command, cmdName, argumentsStartingIndex)
    }
    
    private func findCommandWithShortcut(commandShortcut: String) -> Command? {
        for command in commands {
            if commandShortcut == command.commandShortcut() {
                return command
            }
        }
        
        return nil
    }
    
    private func findCommandWithName(commandName: String) -> Command? {
        for command in commands {
            if commandName == command.commandName() {
                return command
            }
        }
        
        return nil
    }
    
}