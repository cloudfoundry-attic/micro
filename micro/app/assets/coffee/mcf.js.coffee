#= require_self
#= require logger
#= require mcf_date
#= require util
#= require progress_bar
#= require services_table
#= require services_table_row
#= require disabled_service_row
#= require enabled_service_row
#= require util
#= require initialize

# Main Micro Cloud Foundry class.
window.Mcf = class Mcf

  constructor: (@json_root) ->
    @logger = new Logger($('#terminal'))

  # Load all data from the API.
  load_data: (micro_cloud) =>
    @logger.info 'refreshing data'

    @follow_link micro_cloud, 'administrator', null,
      (admin) => @set_admin_email(admin.email)

    @follow_link micro_cloud, 'domain_name', null,
      (domain) => @set_domain(domain.name)

    @follow_link micro_cloud, 'network_interface', null,
      (ni) =>
        @set_gateway ni.gateway
        @set_ip_address ni.ip_address
        @set_is_dhcp ni.is_dhcp
        @set_nameservers ni.nameservers
        @set_netmask ni.netmask

    @follow_link micro_cloud, 'network_health', null,
      (nh) =>
        @set_reach_gateway nh.reach_gateway
        @set_reach_internet nh.reach_internet
        @set_resolve_default(
          nh.resolve_default)
        @set_resolve_other nh.resolve_other

    @refresh_services micro_cloud

    @set_internet_connected micro_cloud.internet_connected
    @set_proxy micro_cloud.http_proxy
    @set_version micro_cloud.version

  configured: ->
    @from_root (data) =>
      if data.is_configured
        $('#not-configured').hide()
        $('#configured').show()
        @load_data(data)
      else
        $('#configured').hide()
        $('#not-configured').show()

  # Update administrator data using the API.
  update_admin: (data, callback, error_callback) =>
    @update_second_level 'administrator', data, callback, error_callback

  # Update domain data using the API.
  update_domain: (data, callback, error_callback) =>
    @update_second_level 'domain_name', data, callback, error_callback

  # Update micro cloud data using the API.
  update_micro_cloud: (data, callback, error_callback) ->
    @from_root (micro_cloud) =>
      @follow_link micro_cloud, 'edit', data, callback, error_callback

  # Update network data using the API.
  update_network: (data, callback, error_callback) =>
    @update_second_level 'network_interface', data, callback, error_callback

  # Rebuild the services table.
  refresh_services: (root_data) ->
    @follow_link root_data, 'services', null,
      (data) => (new ServicesTable(@toggle_service)).render(
        data, $('tbody.services'))

  # Enable or disable a service.
  toggle_service: (name, enabled) =>
    $("#button_#{name}").attr('class', 'btn').text("Pending").unbind()
    @from_root (micro_cloud) =>
      @follow_link micro_cloud, 'services', null,
        (services) =>
          [match] = (service for service in services.services when service.name == name)
          @follow_link match, 'edit', { enabled: enabled }, =>
            @logger.info "#{name} service #{if enabled then 'enabled' else 'disabled'}"
            @refresh_services(micro_cloud)

  # Shut down the Micro Cloud VM.
  shutdown: ->
    @logger.info 'shutting down'
    @update_micro_cloud { is_powered_on: false }



  # Frequently used code path for an edit link on level below the
  # root.
  update_second_level: (rel, data, callback, error_callback = @show_error_pane) ->
    @from_root (micro_cloud) =>
      @follow_link micro_cloud, rel, null, ((child) => @follow_link child, 'edit', data, callback, error_callback)

  from_root: (callback) ->
    $.ajax
      url: @json_root,
      dataType: 'json',
      success: callback,
      error: @handle_error(@show_error_pane)

  # Follow a hyperlink in the hypermedia API.
  follow_link: (data_in, rel, data_next, callback, error_callback = @show_error_pane) ->
    link = data_in._links[rel]
    $.ajax
      url: link.href
      type: link.method
      data: JSON.stringify data_next
      contentType: if data_next then link.type else null
      success: callback
      error: @handle_error(error_callback)

  set_admin_email: (@admin_email) ->
    $('.admin-email').text(@admin_email)

  set_domain: (@domain) ->
    $('.domain').text(@domain)

  set_gateway: (@gateway) ->
    $('.gateway').text(@gateway)

  set_internet_connected: (@internet_connected) ->
    util.bool_css 'internet', @internet_connected

  set_ip_address: (@ip_address) ->
    $('.ip-address').text(@ip_address)

  set_is_dhcp: (@is_dhcp) ->
    $('#dhcp').prop('checked', @is_dhcp).trigger('change')

  set_nameservers: (@nameservers) ->
    $('.nameservers').text(@nameservers.join(', '))

  set_netmask: (@netmask) ->
    $('.netmask').text(@netmask)

  set_proxy: (@proxy) ->
    $('.proxy').text(@proxy)

  set_reach_gateway: (@reach_gateway) ->
    util.bool_css 'reach-gateway', @reach_gateway

  set_reach_internet: (@reach_internet) ->
    util.bool_css 'reach-internet', @reach_internet

  set_resolve_default: (@resolve_default) ->
    util.bool_css 'resolve-default', @resolve_default

  set_resolve_other: (@resolve_other) ->
    util.bool_css 'resolve-other', @resolve_other

  set_version: (@version) ->
    $('.version').text(@version)

  show_error_pane: ->  $('#global-error').show()

  # Handle an AJAX error.
  handle_error: (callback) =>
    (xhr) =>
      if xhr.status == 400 and xhr.responseText?
        $('#global-error-text').text(xhr.responseText)
        @logger.error xhr.responseText

      callback()

  initial_config: (data, success_callback, error_callback) ->
    input = {}

    $.each data, (key, value) ->
      type = switch key
        when 'password', 'email' then 'admin'
        when 'name', 'token' then 'domain'
        when 'ip_address', 'netmask', 'gateway', 'nameservers', 'is_dhcp' then 'network'
        else 'other'
      input[type] ||= {}
      input[type][key] = value

    # TODO: update to use deferred and $.when
    @update_network input.network, =>
      @update_admin input.admin, =>
        @update_domain input.domain, =>
          success_callback()
