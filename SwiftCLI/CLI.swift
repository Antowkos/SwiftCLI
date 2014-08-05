//
//  CLI.swift
//  SwiftCLI
//
//  Created by Jake Heiser on 7/20/14.
//  Copyright (c) 2014 jakeheis. All rights reserved.
//

import Foundation

class CLI: NSObject {
    
    // MARK: - Information
    
    private struct CLIStatic {
        static var appName = ""
        static var appVersion = "1.0"
        static var appDescription = ""
        
        static var commands: [Command] = []
        static var helpCommand: HelpCommand? = HelpCommand()
        static var versionComand: VersionCommand? = VersionCommand()
        static var defaultCommand: Command = CLIStatic.helpCommand!
    }
    
    class func setup(#name: String, version: String = "1.0", description: String = "") {
        CLIStatic.appName = name
        CLIStatic.appVersion = version
        CLIStatic.appDescription = description
    }
    
    class func appName() -> String {
        return CLIStatic.appName
    }
    
    class func appDescription() -> String {
        return CLIStatic.appDescription
    }
    
    // MARK: - Registering commands
    
    class func registerCommand(command: Command) {
        CLIStatic.commands += command;
    }
    
    class func registerCommands(commands: [Command]) {
        for command in commands {
            self.registerCommand(command)
        }
    }
    
    class func registerChainableCommand(#commandName: String) -> ChainableCommand {
        let chainable = ChainableCommand(commandName: commandName)
        CLIStatic.commands += chainable
        return chainable
    }
    
    class func registerCustomHelpCommand(helpCommand: HelpCommand?) {
        CLIStatic.helpCommand = helpCommand
    }
    
    class func registerCustomVersionCommand(versionCommand: VersionCommand?) {
        CLIStatic.versionComand = versionCommand
    }
    
    class func registerDefaultCommand(command: Command) {
        CLIStatic.defaultCommand = command
    }
    
    // MARK: - Go
    
    class func go() -> Bool {
       return self.goWithArguments(NSProcessInfo.processInfo().arguments as [String])
    }
    
    class func debugGoWithArgumentString(argumentString: String) -> Bool {
        let arguments = argumentString.componentsSeparatedByString(" ")
        return self.goWithArguments(arguments)
    }
    
    private class func goWithArguments(arguments: [String]) -> Bool {
        let routingResult = self.routeCommand(arguments: arguments)
        
        switch routingResult {
        case let .Success(command, arguments, options, routedName):
            
            command.options = options;
            let cmdArgs = self.handleCommandOptions(command, routedName: routedName)
            if !cmdArgs {
                return false
            }
            
            if command.showingHelp { // Don't actually execute command if showing help, e.g. git clone -h
                return true
            }
            
            let namedArguments = self.parseSignatureAndArguments(command.commandSignature(), arguments: arguments)
            if !namedArguments {
                return false
            }
            command.arguments = namedArguments!
            
            let result = command.execute()
            
            switch result {
            case .Success:
                return true
            case let .Failure(errorMessage):
                println(errorMessage)
                return false
            }
        case .Failure:
            println("Command not found")
            return false
        }
    }
    
    // MARK: - Privates
    
    class private func routeCommand(#arguments: [String]) -> RouterResult {
        self.prepareForRouting();
        
        var allCommands = CLIStatic.commands
        if let hc = CLIStatic.helpCommand {
            allCommands += hc
        }
        if let vc = CLIStatic.versionComand {
            allCommands += vc
        }
        
        let router = Router(commands: allCommands, arguments: arguments, defaultCommand: CLIStatic.defaultCommand)
        
        return router.route()
    }
    
    class private func parseSignatureAndArguments(signature: String, arguments: [String]) -> NSDictionary? {
        let parser = SignatureParser(signature: signature, arguments: arguments)
        let (namedArguments, errorString) = parser.parse()
        
        if !namedArguments {
            println(errorString!)
            return nil
        }
        
        return namedArguments
    }
    
    class private func handleCommandOptions(command: Command, routedName: String) -> Bool {
        if !command.optionsAccountedFor() {
            if let message = command.options.unaccountedForMessage(command: command, routedName: routedName) {
                println(message)
            }
            if (command.failOnUnrecognizedOptions()) {
                return false
            }
        }
        return true
    }
    
    class private func prepareForRouting() {
        if let hc = CLIStatic.helpCommand {
            hc.allCommands = CLIStatic.commands
        }
    }
    
}
