window.initialize_micro_cloudfoundry = ->
  mcf = new Mcf('/api')

  mcf.load_data()
  $('.close-alert').live 'click', ->
    $(this).closest('.alert').hide()

  $('#dhcp').change ->
    $('.static').prop('disabled', @checked)

  $('#admin-submit').click ->
    bar = new ProgressBar $('#admin-bar')
    bar.start_indeterminate()

    mcf.update_admin {
    email: $('#email').val()
    password: $('#password').val()
    }, ->
      bar.hide()
      mcf.load_data()

  $('#domain-submit').click ->
    bar = new ProgressBar $('#domain-bar')
    bar.start_indeterminate()
    mcf.update_domain {
    name: $('#domain-name').val()
    token: $('#token').val()
    }, ->
      bar.hide()
      mcf.load_data()

  $('#internet-on-submit').click ->
    bar = new ProgressBar $('#internet-bar')
    bar.start_indeterminate()
    mcf.update_micro_cloud {
    internet_connected: true
    }, ->
      bar.hide()
      mcf.load_data()

  $('#internet-off-submit').click ->
    bar = new ProgressBar $('#internet-bar')
    bar.start_indeterminate()
    mcf.update_micro_cloud {
    internet_connected: false
    }, ->
      bar.hide()
      mcf.load_data()

  $('#network-submit').click ->
    bar = new ProgressBar $('#network-bar')
    bar.start_indeterminate()
    mcf.update_network {
    name: 'eth0'
    ip_address: $('#ip-address').val()
    netmask: $('#netmask').val()
    gateway: $('#gateway').val()
    nameservers: $('#nameservers').val().split(',')
    is_dhcp: $('#dhcp').is(':checked')
    }, ->
      bar.hide()
      mcf.load_data()

  $('#proxy-submit').click ->
    bar = new ProgressBar $('#proxy-bar')
    bar.start_indeterminate()
    mcf.update_micro_cloud { http_proxy: $('#proxy').val() }, ->
      bar.hide()
      mcf.load_data()

  $('#shutdown-submit').click ->
    mcf.shutdown()
    $('#shutdown-modal').modal('hide')
