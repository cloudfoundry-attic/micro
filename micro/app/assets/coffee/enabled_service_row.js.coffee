window.EnabledServiceRow = class EnabledServiceRow extends ServicesTableRow

  enabled: -> true

  button_class: -> 'btn-danger'

  button_text: -> 'Stop'

  icon: -> 'icon-stop'

  tr_class: -> if @ok() then 'success' else 'error'