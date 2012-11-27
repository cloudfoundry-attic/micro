# Main Micro Cloud Foundry class.
class Mcf

        constructor: (@json_root) ->
                @logger = new Logger($('#terminal'))

        # Load all data from the API.
        load_data: =>
                @logger.info 'refreshing data'

                @from_root (micro_cloud) =>
                        @follow_link micro_cloud, 'administrator',
                                (admin) => @set_admin_email(admin.email)

                        @follow_link micro_cloud, 'domain_name',
                                (domain) => @set_domain(domain.name)

                        @follow_link micro_cloud, 'network_interface',
                                (ni) =>
                                        @set_gateway ni.gateway
                                        @set_ip_address ni.ip_address
                                        @set_is_dhcp ni.is_dhcp
                                        @set_nameservers ni.nameservers
                                        @set_netmask ni.netmask

                        @follow_link micro_cloud, 'network_health',
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

        # Update administrator data using the API.
        update_admin: (data, callback) =>
                @update_second_level 'administrator', data, callback

        # Update domain data using the API.
        update_domain: (data, callback) =>
                @update_second_level 'domain_name', data, callback

        # Update micro cloud data using the API.
        update_micro_cloud: (data, callback) ->
                @from_root (micro_cloud) =>
                        @follow_link micro_cloud, 'edit', callback, data

        # Update network data using the API.
        update_network: (data, callback) =>
                @update_second_level 'network_interface', data, callback

        # Frequently used code path for an edit link on level below the
        # root.
        update_second_level: (rel, data, callback) ->
                @from_root (micro_cloud) =>
                        @follow_link micro_cloud, rel,
                                (child) => @follow_link child, 'edit',
                                        callback, data

        from_root: (callback) ->
                $.getJSON(@json_root, callback)

        # Follow a hyperlink in the hypermedia API.
        follow_link: (data_in, rel, callback, data_next) ->
                link = data_in._links[rel]

                $.ajax
                        url: link.href
                        type: link.method
                        data: JSON.stringify data_next
                        contentType: if data_next then link.type else null
                        success: callback
                        error: @ajax_error

        # Rebuild the services table.
        refresh_services: (root_data) ->
                @follow_link root_data, 'services',
                        (data) => (new ServicesTable(@toggle_service)).render(
                                data, $('tbody.services'))

        # Enable or disable a service.
        toggle_service: (name, enabled) =>
                @from_root (micro_cloud) =>
                        @follow_link micro_cloud, 'services',
                                (services) =>
                                        [match] = (service for service in services.services when service.name == name)
                                        @follow_link match, 'edit',
                                                =>
                                                        @logger.info "#{name} service #{if enabled then 'enabled' else 'disabled'}"
                                                        @refresh_services(micro_cloud)
                                                { enabled : enabled }

        # Shut down the Micro Cloud VM.
        shutdown: ->
                @logger.info 'shutting down'
                @update_micro_cloud { is_powered_on: false }

        set_admin_email: (@admin_email) ->
                $('.admin-email').text(@admin_email)

        set_domain: (@domain) ->
                $('.domain').text(@domain)

        set_gateway: (@gateway) ->
                $('.gateway').text(@gateway)

        set_internet_connected: (@internet_connected) ->
                bool_css 'internet', @internet_connected

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
                bool_css 'reach-gateway', @reach_gateway

        set_reach_internet: (@reach_internet) ->
                bool_css 'reach-internet', @reach_internet

        set_resolve_default: (@resolve_default) ->
                bool_css 'resolve-default', @resolve_default

        set_resolve_other: (@resolve_other) ->
                bool_css 'resolve-other', @resolve_other

        set_version: (@version) ->
                $('.version').text(@version)

        # Handle an AJAX error.
        ajax_error: (xhr) =>
                if xhr.status == 400 and xhr.responseText?
                        @logger.error xhr.responseText

class ServicesTable

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

class ServicesTableRow

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
                $('<a />').attr('href', '#').addClass(
                        "btn #{@button_class()}"
                ).append($('<i />').addClass(@icon())).append(
                        " #{@button_text()}").click( =>
                                @button_callback(@name, !@enabled()))

        ok: -> @health == 'ok'

        row: -> $('<tr />').addClass(@tr_class())

class EnabledServiceRow extends ServicesTableRow

        enabled: -> true

        button_class: -> 'btn-danger'

        button_text: -> 'Stop'

        icon: -> 'icon-stop'

        tr_class: -> if @ok() then 'success' else 'error'

class DisabledServiceRow extends ServicesTableRow

        enabled: -> false

        button_class: -> 'btn-success'

        button_text: -> 'Start'

        icon: -> 'icon-play'

        tr_class: -> 'warning'

class McfDate

        constructor: (js_date = new Date()) ->
                @js_date = js_date

        # Format this date.
        to_s: -> [
                leading_zero_pad(@js_date.getMonth() + 1, 2)
                '-'
                leading_zero_pad(@js_date.getDate(), 2)
                ' '
                leading_zero_pad(@js_date.getHours(), 2)
                ':'
                leading_zero_pad(@js_date.getMinutes(), 2)
                ':'
                leading_zero_pad(@js_date.getSeconds(), 2)
                '.'
                leading_zero_pad(@js_date.getMilliseconds(), 3)
                ].join ''

class Logger

        constructor: (@dom_element) ->

        debug: (s) => @log s, 'logger-debug'

        info: (s) => @log s, 'logger-info'

        warn: (s) => @log s, 'logger-warn'

        error: (s) => @log s, 'logger-error'

        log: (s, style) ->
                text = if style? then $('<span />').addClass(style).append(s) else s

                @dom_element.prepend("\n").prepend(text).prepend(' ').prepend(
                        Logger.date())

        @date: ->
                $('<span />').addClass('logger-date').text(
                        (new McfDate()).to_s())

# A fake progress bar for synchronous API calls.
class ProgressBar

        constructor: (@dom_element) ->
                @reset()

        reset: ->
                @progress = 0
                @dom_element.css 'width', '0%'

        # Update the bar from 0 to 100% over a specified length of time.
        update_for: (@milliseconds) ->
                @reset()
                @show()

                @interval = setInterval =>
                        @progress += 1
                        @dom_element.css 'width', "#{@progress}%"
                        if @progress >= 100
                                @stop()
                , @milliseconds / 100

        stop: ->
                clearInterval @interval

        container: ->
                @dom_element.parent()

        show: ->
                @container().show()

        hide: ->
                @container().hide()

# Show and hide CSS based on boolean variables.
#
# Passing in name = test enabled = true will show elements with the CSS classes
# 'name' and 'enabled' and hide elements with the CSS classes 'name' and
# 'disabled'.
bool_css = (name, enabled) ->
        if enabled
                show_str = 'enabled'
                hide_str = 'disabled'
        else
                show_str = 'disabled'
                hide_str = 'enabled'

        $(".#{name}.#{show_str}").show()
        $(".#{name}.#{hide_str}").hide()

# Add a leading zero to numbers with less than the desired number of digits.
leading_zero_pad = (n, digits) ->
        s = n.toString()

        zeroes = ('0' for x in [0...Math.max(0, digits - s.length)]).join('')

        "#{zeroes}#{s}"

$(document).ready ->
        mcf = new Mcf('/api')

        mcf.load_data()

        $('#dhcp').change ->
                $('.static').prop('disabled', @checked)

        $('#admin-submit').click ->
                bar = new ProgressBar $('#admin-bar')
                bar.update_for 100000

                mcf.update_admin {
                        email : $('#email').val()
                        password : $('#password').val()
                        }, ->
                        bar.hide()
                        mcf.load_data()

        $('#domain-submit').click ->
                bar = new ProgressBar $('#domain-bar')
                bar.update_for 100000
                mcf.update_domain {
                        name : $('#domain-name').val()
                        token : $('#token').val()
                        }, ->
                        bar.hide()
                        mcf.load_data()

        $('#internet-on-submit').click ->
                bar = new ProgressBar $('#internet-bar')
                bar.update_for 3000
                mcf.update_micro_cloud {
                        internet_connected : true
                        }, ->
                        bar.hide()
                        mcf.load_data()

        $('#internet-off-submit').click ->
                bar = new ProgressBar $('#internet-bar')
                bar.update_for 3000
                mcf.update_micro_cloud {
                        internet_connected : false
                        }, ->
                        bar.hide()
                        mcf.load_data()

        $('#network-submit').click ->
                bar = new ProgressBar $('#network-bar')
                bar.update_for 8000
                mcf.update_network {
                        name: 'eth0'
                        ip_address : $('#ip-address').val()
                        netmask : $('#netmask').val()
                        gateway : $('#gateway').val()
                        nameservers : $('#nameservers').val().split(',')
                        is_dhcp: $('#dhcp').is(':checked')
                        }, ->
                        bar.hide()
                        mcf.load_data()

        $('#proxy-submit').click ->
                bar = new ProgressBar $('#proxy-bar')
                bar.update_for 50000
                mcf.update_micro_cloud { http_proxy : $('#proxy').val() }, ->
                        bar.hide()
                        mcf.load_data()

        $('#shutdown-submit').click ->
                mcf.shutdown()
                $('#shutdown-modal').modal('hide')
