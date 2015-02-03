Promise        = require "bluebird"
fs             = require "fs"
path           = require "path"
{EventEmitter} = require "events"
{Range}        = require "atom"

module.exports =
  class NamespaceGuesser extends EventEmitter
    inject: (editor) ->

      new Promise (resolve, reject) ->
        if editor.getGrammar().scopeName isnt "text.html.php"
          reject new Error "Buffer must be a PHP script"
        resolve editor.getPath()

      .then =>
        @guessNamespace editor.getPath()

      .then (namespace)->
        if namespace is null
          throw new Error "Unable to guess namespace"
        console.log "namespace for #{editor.getPath()} is #{namespace}"

        # Remove other namespace and return range if there's a match
        range = undefined
        editor.scan /^\s*\bnamespace\b.*$/, (object)->
          range = object.range

        text = "namespace #{namespace};"
        unless range
          range = new Range [1, 0], [1, 0]
          text = "#{text}\n\n"

        editor.setTextInBufferRange range, text

      .catch (error)=>
        console.error "error: ", error
        @emit "error", error

    loadNamespacePrefixes: (filepath)->
      console.info "info: loading namespace prefixes"
      current_path = filepath

      # Recursivily looking up for a composer.json
      while not fs.existsSync "#{current_path}/composer.json"
        previous_path = current_path
        current_path  = path.join current_path, ".."

        if current_path is previous_path
          throw new Error "no composer.json found"

      pkg = require "#{current_path}/composer.json"

      prefixes = []

      if pkg.autoload['psr-0']?
        for prefix, src of pkg.autoload['psr-0']
          prefixes[path.join current_path, src.replace /\/$/, ''] = prefix

      return prefixes

    guessNamespace: (filepath)->
      console.info "info: try to guess a namespace"
      namespace = null
      for src, prefix of @loadNamespacePrefixes filepath
        if filepath.startsWith src
          namespace = [
            prefix
            ((path.dirname filepath).replace src, "").replace /\//g, '\\'
          ].join '\\'
          break

      return namespace
        .replace /\\{2,}/, '\\'
        .replace /^\\/, ''
