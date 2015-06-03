NamespaceGuesser = require "./namespace-guesser"

module.exports =

  injectNamespaceStatement: ->
    editor  = atom.workspace.getActiveTextEditor()
    nsi     = new NamespaceGuesser
    nsi.inject editor

  injectUseStatement: ->
    editor  = atom.workspace.getActiveTextEditor()
    nsi     = new NamespaceGuesser


  expandFQCN: ->
    editor  = atom.workspace.getActiveTextEditor()
    nsi     = new NamespaceGuesser


  activate: (state) ->

    atom.commands.add "atom-text-editor",
      "php-fellow:inject-namespace-stmt": => @injectNamespaceStatement()
      "php-fellow:inject-use-stmt":       => @injectUseStatement()
      "php-fellow:expand-fqcn":           => @expandFQCN()

  deactivate: ->

  serialize: ->
