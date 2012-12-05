window.Logger = class Logger

  constructor: (@dom_element) ->

  debug: (s) => @log s, 'logger-debug'

  info: (s) => @log s, 'logger-info'

  warn: (s) => @log s, 'logger-warn'

  error: (s) => @log s, 'logger-error'

  log: (s, style) ->
    text = if style? then $('<span />').addClass(style).append(s) else s

    @dom_element.prepend("\n").prepend(text).prepend(' ').prepend(
      Logger.date())

  @date: ->
    $('<span />').addClass('logger-date').text(
      (new McfDate()).to_s())
