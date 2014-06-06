Q              = require "q"
fs             = require "fs"
path           = require "path"
{EventEmitter} = require "events"

module.exports =
  class NamespaceGuesser extends EventEmitter
    inject: (editor) ->

      Q.fcall ->
        if editor.getGrammar().scopeName isnt "text.html.php"
          throw new Error "Buffer must be a PHP script"
        return editor.getPath()

      .then =>
        @guessNamespace editor.getPath()

      .then (namespace)->
        if namespace is null
          throw new Error "Unable to guess namespace"
        console.log "namespace for #{editor.getPath()} is #{namespace}"

      .fail (error)=>
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

      return namespace.replace /\\{2,}/, '\\'
