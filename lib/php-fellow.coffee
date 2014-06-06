NamespaceGuesser = require "./namespace-guesser"

module.exports =

  injectNamespaceStatement: ->
    editor  = atom.workspace.getActiveEditor()
    nsi     = new NamespaceGuesser
    nsi.inject(editor)

  injectUseStatement: ->
    console.info "inject use"

  expandFQCN: ->
    console.info "expand FQCN"

  activate: (state) ->

    atom.workspaceView.command "php-fellow:inject-namespace-stmt"
      , ".editor"
      , => @injectNamespaceStatement()

    atom.workspaceView.command "php-fellow:inject-use-stmt"
      , ".editor"
      , => @injectUseStatement()

    atom.workspaceView.command "php-fellow:expand-fqcn"
      , ".editor"
      , => @expandFQCN()

  deactivate: ->

  serialize: ->
