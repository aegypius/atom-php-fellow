{WorkspaceView} = require 'atom'
PhpCompanion = require '../lib/php-fellow'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "PhpFellow", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('php-fellow')

  describe "when the php-fellow:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.php-fellow')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.workspaceView.trigger 'php-fellow:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.php-fellow')).toExist()
        atom.workspaceView.trigger 'php-fellow:toggle'
        expect(atom.workspaceView.find('.php-fellow')).not.toExist()
