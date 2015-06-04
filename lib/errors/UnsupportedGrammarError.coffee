UnsupportedGrammarError = (message)->
  @name    = 'UnsupportedGrammarError'
  @message = message or 'Unsupported Grammar'

UnsupportedGrammarError.prototype = Object.create Error.prototype
UnsupportedGrammarError.constructor = UnsupportedGrammarError

module.exports = UnsupportedGrammarError
