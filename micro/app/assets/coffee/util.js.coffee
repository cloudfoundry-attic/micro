# Show and hide CSS based on boolean variables.
#
# Passing in name = test enabled = true will show elements with the CSS classes
# 'name' and 'enabled' and hide elements with the CSS classes 'name' and
# 'disabled'.

window.Util = class Util
  bool_css : (name, enabled) ->
    if enabled
      show_str = 'enabled'
      hide_str = 'disabled'
    else
      show_str = 'disabled'
      hide_str = 'enabled'

    $(".#{name}.#{show_str}").show()
    $(".#{name}.#{hide_str}").hide()

  # Add a leading zero to numbers with less than the desired number of digits.
  leading_zero_pad : (n, digits) ->
    s = n.toString()

    zeroes = ('0' for x in [0...Math.max(0, digits - s.length)]).join('')

    "#{zeroes}#{s}"

window.util = new Util