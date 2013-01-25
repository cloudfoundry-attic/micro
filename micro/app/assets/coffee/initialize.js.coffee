window.initialize_micro_cloudfoundry = (mcf) ->
  mcf ||= new Mcf '/api'

  showConfigured = ->
    $('#not-configured').hide()
    $('#configured').show()

  mcf.configured showConfigured, ->
    $('#not-configured').show()
    $('#configured').hide()

  submit = (progress_bar, method, data) ->
    bar = new ProgressBar $(progress_bar)
    bar.start_indeterminate()
    $(this).attr 'disabled', 'disabled'
    mcf[method] data, =>
      mcf.configured showConfigured, $.noop
      bar.hide()
      $(this).attr 'disabled', null
    , =>
      mcf.show_error_pane()
      bar.hide()
      $(this).attr 'disabled', null

  add_network = (data) ->
    if $('#initial-network-static').is ':checked'
      $.extend data,
        ip: $('#initial-ip-address').val()
        netmask: $('#initial-netmask').val()
        gateway: $('#initial-gateway').val()
        nameservers: $('#initial-nameservers').val()
        is_dhcp: false
    else if $('#initial-network-dhcp').is ':checked'
      data.is_dhcp = true

  add_domain = (data) ->
    if $('#initial-domain-private').is ':checked'
      $.extend data,
        name: $('#initial-domain-offline').val()
    else if $('#initial-domain-public').is ':checked'
      data.token = $('#initial-domain-token').val()

  $('#admin-submit').on 'click', ->
    submit.call this, '#admin-bar', 'update_admin',
      password: $('#password').val()

  $('#domain-submit').on 'click', ->
    submit.call this, '#domain-bar', 'update_domain',
      name: $('#domain-name').val()
      token: $('#token').val()

  $('#internet-on-submit').on 'click', ->
    submit.call this, '#internet-bar', 'update_micro_cloud', internet_connected: true

  $('#internet-off-submit').on 'click', ->
    submit.call this, '#internet-bar', 'update_micro_cloud', internet_connected: false

  $('#proxy-submit').on 'click', ->
    submit.call this, '#proxy-bar', 'update_micro_cloud', http_proxy: $('#proxy').val()

  $('#shutdown-submit').on 'click', ->
    mcf.shutdown()
    $('#shutdown-modal').modal('hide')

  $('#dhcp').on 'change', ->
    $('.static').prop('disabled', @checked)

  $('.close-alert').on 'click', ->
    $(this).closest('.alert').hide()

  $('#network-submit').on 'click', ->
    submit.call this, '#network-bar', 'update_network',
      name: 'eth0'
      ip_address: $('#ip-address').val()
      netmask: $('#netmask').val()
      gateway: $('#gateway').val()
      nameservers: $('#nameservers').val().split(',')
      is_dhcp: $('#dhcp').is(':checked')

  $('#initial-submit').on 'click', ->
    data = password: $('#initial-password').val()
    add_domain data
    add_network data
    submit.call this, '#initial-bar', 'initial_config', data

  $('.accordion-toggle').on 'click', ->
    $(this).children(':radio').prop('checked', true)

  $('.accordion-toggle > :radio').on 'click', ->
      # setTimeout is a hack to make the radio buttons select when clicked
      setTimeout =>
        $(this).prop('checked', true)
      , 10
