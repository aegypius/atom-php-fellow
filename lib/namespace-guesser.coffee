fs                        = require "fs"
path                      = require "path"
{EventEmitter}            = require "events"
{Range}                   = require "atom"
{UnsupportedGrammarError} = require "./errors"

module.exports =
  class NamespaceGuesser extends EventEmitter
    inject: (editor) ->

      new Promise (resolve, reject) ->
        if editor.getGrammar().scopeName isnt "text.html.php"
          reject new UnsupportedGrammarError
        resolve editor.getPath()

      .then =>
        @guessNamespace editor.getPath()

      .then (namespace)->
        if namespace is null or namespace is ""
          throw new Error "Unable to guess namespace"

        atom.notifications.addSuccess "Namespace updated to #{namespace}"

        # Remove other namespace and return range if there's a match
        range = undefined
        editor.scan /^\s*\bnamespace\b.*\r?\n*$/m, (object)->
          range = object.range

        text = "\nnamespace #{namespace};\n"
        unless range
          range = new Range [1, 0], [1, 0]

        editor.setTextInBufferRange range, text

      .catch (error)=>
        if error.message? and error not instanceof UnsupportedGrammarError
          atom.notifications.addError error.message

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

      for section in ['autoload', 'autoload-dev']
        if pkg[section]?

          # PSR Autoloading
          for psr in ['psr-0', 'psr-4']
            if pkg[section][psr]?
              for prefix, src of pkg[section][psr]
                prefixes[path.join current_path, src.replace /\/$/, ''] = prefix

      return prefixes

    guessNamespace: (filepath)->
      console.info "info: try to guess a namespace"
      namespace = ""
      if filepath is undefined
        throw new Error "You must save your file before."
      else
        for src, prefix of @loadNamespacePrefixes filepath
          if filepath.startsWith src
            namespace = [
              prefix
              ((path.dirname filepath).replace src, "").replace /\//g, '\\'
            ].join '\\'
            break

        namespace
          .replace /\\{2,}/, '\\'
          .replace /^\\/, ''
          .replace /\\$/, ''
