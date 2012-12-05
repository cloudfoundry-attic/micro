window.ServicesTable = class ServicesTable

  constructor: (@button_callback) ->

    # Render the services table and attach it to a DOM element.
  render: (data, element) ->
    element.empty()

    element.append(@create_row(
      service).render()) for service in data.services when @show_service(service.name)

  create_row: (row_data) ->
    if row_data.enabled
      new EnabledServiceRow row_data.health, row_data.name,
      @button_callback
    else
      new DisabledServiceRow row_data.health, row_data.name,
      @button_callback

  # Return true if the service should be shown in the UI.
  show_service: (service_name) ->
    service_name not in [
      'core'
    ]
