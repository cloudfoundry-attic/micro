window.DisabledServiceRow = class DisabledServiceRow extends ServicesTableRow

  enabled: -> false

  button_class: -> 'btn-success'

  button_text: -> 'Start'

  icon: -> 'icon-play'

  tr_class: -> 'warning'
