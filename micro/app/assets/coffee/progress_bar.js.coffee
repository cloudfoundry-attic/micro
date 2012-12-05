# A fake progress bar for synchronous API calls.
window.ProgressBar = class ProgressBar

  constructor: (@dom_element) ->
    @reset()

  reset: ->
    @progress = 0
    @dom_element.css 'width', '0%'

  # Update the bar from 0 to 100% over a specified length of time.
  update_for: (@milliseconds) ->
    @reset()
    @show()

    @interval = setInterval =>
      @progress += 1
      @dom_element.css 'width', "#{@progress}%"
      if @progress >= 100
        @stop()
    , @milliseconds / 100

  stop: ->
    clearInterval @interval

  container: ->
    @dom_element.parent()

  show: ->
    @container().show()

  hide: ->
    @container().hide()