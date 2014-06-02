PhpFellowView = require './php-fellow-view'

module.exports =
  phpFellowView: null

  activate: (state) ->
    @phpFellowView = new PhpCompanionView(state.phpFellowViewState)

  deactivate: ->
    @phpFellowView.destroy()

  serialize: ->
    phpFellowViewState: @phpFellowView.serialize()
