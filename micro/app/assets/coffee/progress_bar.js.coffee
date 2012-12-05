# A fake progress bar for synchronous API calls.
window.ProgressBar = class ProgressBar

  constructor: (@dom_element) ->

  start_indeterminate: ->
    @dom_element.css 'width', '100%'
    @show()

  container: ->
    @dom_element.parent()

  show: ->
    @container().show()

  hide: ->
    @container().hide()