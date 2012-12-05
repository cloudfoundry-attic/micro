window.ServicesTableRow = class ServicesTableRow

  constructor: (@health, @name, @button_callback) ->

    # Create a services table row.
  render: ->
    @row().append(
      $('<td />').append(
        $('<strong />').text(@name))
    ).append(
      $('<td />').text(@health)
    ).append(
      $('<td />').text(@enabled)
    ).append(
      $('<td />').append(@button())
    )

  button: ->
    $('<a />').attr({href: '#', id: "button_#{@name}"}).addClass(
      "btn #{@button_class()}"
    ).append($('<i />').addClass(@icon())).append(
      " #{@button_text()}").click( =>
      @button_callback(@name, !@enabled()))

  ok: -> @health == 'ok'

  row: -> $('<tr />').addClass(@tr_class())

