window.initialize_micro_cloudfoundry = (mcf) ->
  mcf ||= new Mcf '/api'

  admin_submit = ->
    bar = new ProgressBar $('#admin-bar')
    bar.start_indeterminate()
    $(this).attr 'disabled', 'disabled'
    mcf.update_admin
      email: $('#email').val()
      password: $('#password').val()
    , =>
      bar.hide()
      mcf.load_data()
      $(this).attr 'disabled', null

  domain_submit = ->
    bar = new ProgressBar $('#domain-bar')
    bar.start_indeterminate()
    $(this).attr 'disabled', 'disabled'
    mcf.update_domain {
      name: $('#domain-name').val()
      token: $('#token').val()
    }, =>
      bar.hide()
      mcf.load_data()
      $(this).attr 'disabled', null

  internet_on_submit = ->
    bar = new ProgressBar $('#internet-bar')
    bar.start_indeterminate()
    $(this).attr 'disabled', 'disabled'
    mcf.update_micro_cloud {
      internet_connected: true
    }, =>
      bar.hide()
      mcf.load_data()
      $(this).attr 'disabled', null

  internet_off_submit = ->
    bar = new ProgressBar $('#internet-bar')
    bar.start_indeterminate()
    $(this).attr 'disabled', 'disabled'
    mcf.update_micro_cloud {
      internet_connected: false
    }, =>
      bar.hide()
      mcf.load_data()
      $(this).attr 'disabled', null

  network_submit = ->
    bar = new ProgressBar $('#network-bar')
    bar.start_indeterminate()
    $(this).attr 'disabled', 'disabled'
    mcf.update_network {
      name: 'eth0'
      ip_address: $('#ip-address').val()
      netmask: $('#netmask').val()
      gateway: $('#gateway').val()
      nameservers: $('#nameservers').val().split(',')
      is_dhcp: $('#dhcp').is(':checked')
    }, =>
      bar.hide()
      mcf.load_data()
      $(this).attr 'disabled', null

  proxy_submit = ->
    bar = new ProgressBar $('#proxy-bar')
    bar.start_indeterminate()
    $(this).attr 'disabled', 'disabled'
    mcf.update_micro_cloud { http_proxy: $('#proxy').val() }, =>
      bar.hide()
      mcf.load_data()
      $(this).attr 'disabled', null

  shutdown_submit = ->
    mcf.shutdown()
    $('#shutdown-modal').modal('hide')

  dhcp = ->
    $('.static').prop('disabled', @checked)

  close_alert = ->
    $(this).closest('.alert').hide()

  mcf.load_data()

  $('.close-alert').on 'click', close_alert
  $('#dhcp').on 'change', dhcp
  $('#admin-submit').on 'click', admin_submit
  $('#domain-submit').on 'click', domain_submit
  $('#internet-on-submit').on 'click', internet_on_submit
  $('#internet-off-submit').on 'click', internet_off_submit
  $('#network-submit').on 'click', network_submit
  $('#proxy-submit').on 'click', proxy_submit
  $('#shutdown-submit').on 'click', shutdown_submit


