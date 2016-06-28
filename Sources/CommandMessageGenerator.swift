//
//  CommandMessageGenerator.swift
//  Example
//
//  Created by Jake Heiser on 6/13/15.
//  Copyright © 2015 jakeheis. All rights reserved.
//

class CommandMessageGenerator {
    
    class func generateUsageStatement(command: CommandType, options: Options?) -> String {
        var message = "Usage: \(CLI.appName)"
        
        if !command.commandName.isEmpty {
            message += " \(command.commandName)"
        }
        
        if !command.commandSignature.isEmpty {
            message += " \(command.commandSignature)"
        }
        
        if let options = options where !options.options.isEmpty {
            message += " [options]\n"
            
            let sortedOptions = options.options.sorted { (lhs, rhs) in
                return lhs.options.first < rhs.options.first
            }
            for option in sortedOptions {
                let usage = option.usage
                message += "\n\(usage)"
            }
            
            message += "\n"
        } else {
            message += "     (no options)\n"
        }
        
        return message
    }
    
    class func generateMisusedOptionsStatement(command: CommandType, options: Options) -> String? {
        guard let optionsCommand = command as? OptionCommandType else {
            return nil
        }
        
        switch optionsCommand.unrecognizedOptionsPrintingBehavior {
        case .PrintNone:
            return nil
        case .PrintOnlyUsage:
            return generateUsageStatement(command: command, options: options)
        case .PrintOnlyUnrecognizedOptions:
            return options.misusedOptionsMessage()
        case .PrintAll:
            return generateUsageStatement(command: command, options: options) + "\n" + options.misusedOptionsMessage()
        }
    }
    
}
