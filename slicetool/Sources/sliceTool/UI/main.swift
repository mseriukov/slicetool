
var registry = CommandRegistry(usage: "<command> <options>", overview: "Basic Slicer")
registry.register(command: SliceToSVGCommand.self)
registry.run()

