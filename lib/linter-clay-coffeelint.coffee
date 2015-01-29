linterPath = atom.packages.getLoadedPackage('linter').path
Linter = require "#{linterPath}/lib/linter"
findFile = require "#{linterPath}/lib/util"
path = require 'path'

class LinterCoffeelint extends Linter
  # The syntax that the linter handles. May be a string or
  # list/tuple of strings. Names should be all lowercase.
  @syntax: ['source.coffee', 'source.litcoffee']

  # A string, list, tuple or callable that returns a string, list or tuple,
  # containing the command line (with arguments) used to lint.
  cmd: 'coffeelint --reporter jslint'

  linterName: 'coffeelint'

  # A regex pattern used to extract information from the executable's output.
  regex:
    '<issue line="(?<line>\\d+)"' +
    # '.+?lineEnd="\\d+"' +
    '.+?reason="\\[((?<error>error)|(?<warning>warn))\\] (?<message>.+?)"'

  regexFlags: 's'

  isNodeExecutable: yes

  configPath: null

  constructor: (editor) ->
    super(editor)

    atom.config.observe 'linter-clay-coffeelint.coffeelintConfigPath', =>
      @configPath = atom.config.get 'linter-clay-coffeelint.coffeelintConfigPath'

    if configPathLocal = findFile(@cwd, ['coffeelint.json'])
      @cmd += " -f #{configPathLocal}"
    else if @configPath
      @cmd += " -f #{@configPath}"
    else
      selfPath = atom.packages.resolvePackagePath('linter-clay-coffeelint')
      configPath = 'node_modules/clay-coffeescript-style-guide/coffeelint.json'
      @cmd += " -f #{path.join(selfPath, configPath)}"

    atom.config.observe 'linter-clay-coffeelint.coffeelintExecutablePath', =>
      @executablePath = atom.config.get 'linter-clay-coffeelint.coffeelintExecutablePath'

    if editor.getGrammar().scopeName is 'source.litcoffee'
      @cmd += ' --literate'

  destroy: ->
    atom.config.unobserve 'linter-clay-coffeelint.coffeelintExecutablePath'
    atom.config.unobserve 'linter-clay-coffeelint.coffeelintConfigPath'

module.exports = LinterCoffeelint
