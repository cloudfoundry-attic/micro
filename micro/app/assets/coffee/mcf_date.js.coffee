window.McfDate = class McfDate

  constructor: (js_date = new Date()) ->
    @js_date = js_date

  # Format this date.
  to_s: -> [
    util.leading_zero_pad(@js_date.getMonth() + 1, 2)
    '-'
    util.leading_zero_pad(@js_date.getDate(), 2)
    ' '
    util.leading_zero_pad(@js_date.getHours(), 2)
    ':'
    util.leading_zero_pad(@js_date.getMinutes(), 2)
    ':'
    util.leading_zero_pad(@js_date.getSeconds(), 2)
    '.'
    util.leading_zero_pad(@js_date.getMilliseconds(), 3)
  ].join ''
