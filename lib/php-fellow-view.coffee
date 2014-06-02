{View} = require 'atom'

module.exports =
class PhpFellowView extends View
  @content: ->
    @div class: 'php-fellow overlay from-top', =>
      @div "The PhpFellow package is Alive! It's ALIVE!", class: "message"

  initialize: (serializeState) ->
    atom.workspaceView.command "php-fellow:toggle", => @toggle()

  # Returns an object that can be retrieved when package is activated
  serialize: ->

  # Tear down any state and detach
  destroy: ->
    @detach()

  toggle: ->
    console.log "PhpFellowView was toggled!"
    if @hasParent()
      @detach()
    else
      atom.workspaceView.append(this)
