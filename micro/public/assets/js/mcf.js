var MCF = (function (window, $) {
    "use strict";

    var my = {},
        jsonRoot = '/api';

    function showAjaxError(xhr) {
        alert(xhr.responseText);
    }

    function followLink(dataIn, rel, callback, dataNext) {
        var link = dataIn._links[rel];

        $.ajax({
            url: link.href,
            type: link.method,
            data: JSON.stringify(dataNext),
            contentType: dataNext ? link.type : null,
            success: callback,
            error: showAjaxError
        });
    }

    function fromRoot(nextFunction) {
        $.getJSON(jsonRoot, nextFunction);
    }

    function changeAdmin(vals) {
        fromRoot(function (data) {
            followLink(data, 'administrator', function (data) {
                followLink(data, 'edit', my.loadData, vals);
            });
        });
    }

    function changeDomain(vals) {
        fromRoot(function (data) {
            followLink(data, 'domain_name', function (data) {
                followLink(data, 'edit', my.loadData, vals);
            });
        });
    }

    function changeMicroCloud(val) {
        fromRoot(function (data) {
            followLink(data, 'edit', my.loadData, val);
        });
    }

    function changeNetwork(vals) {
        fromRoot(function (data) {
            followLink(data, 'network_interface', function (data) {
                followLink(data, 'edit', my.loadData, vals);
            });
        });
    }

    function servicesTableRow(data) {
        var trClass,
            buttonClass = data.enabled ? 'btn-danger' : 'btn-success',
            buttonText = data.enabled ? 'Stop' : 'Start',
            icon = data.enabled ? 'icon-stop' : 'icon-play',
            button;

        if (data.enabled) {
            if (data.health === 'ok') {
                trClass = 'success';
            } else {
                trClass = 'error';
            }
        } else {
            trClass = 'warning';
        }

        button = $('<a />').attr('href', '#').addClass(
            'btn ' + buttonClass
        ).append($('<i />').addClass(icon)).append(' ' + buttonText);

        button.click(function () {
            toggleService(data.name, !data.enabled);
        });

        return $('<tr />').addClass(trClass).append(
            $('<td />').append($('<strong />').text(data.name))
        ).append(
            $('<td />').text(data.health)
        ).append(
            $('<td />').text(data.enabled)
        ).append(
            $('<td />').append(button)
        );
    }

    function refreshServices(rootData) {
        followLink(rootData, 'services', function (data) {
            var servicesTable = $('tbody.services');

            servicesTable.empty();
            data.services.forEach(function (service) {
                servicesTable.append(servicesTableRow(service));
            });
        });
    }

    function toggleService(name, enabled) {
        fromRoot(function (rootData) {
            followLink(rootData, 'services', function (data) {
                $.each(data.services, function (index, service) {
                    if (service.name === name) {
                        followLink(service, 'edit', function () {
                            refreshServices(rootData);
                        }, { enabled : enabled });

                        return false;
                    }
                });
            });
        });
    }

    my.loadData = function () {
        fromRoot(function (data) {
            followLink(data, 'domain_name', function (data) {
                $('.domain').text(data.name);
            });

            followLink(data, 'administrator', function (data) {
                $('.admin-email').text(data.email);
            });

            followLink(data, 'network_interface', function (data) {
                $('.ip_address').text(data.ip_address);
                $('.netmask').text(data.netmask);
                $('.gateway').text(data.gateway);
                $('.nameservers').text(data.nameservers.join(', '));

                if (data.is_dhcp) {
                    $('#dhcp').prop('checked', true);
                }
            });

            followLink(data, 'network_health', function (data) {
                $('.reach-internet').text(data.reach_internet);
                $('.reach-gateway').text(data.reach_gateway);
                $('.resolve-default').text(data.resolve_default);
                $('.resolve-other').text(data.resolve_other);
            });

            $('.proxy').text(data.http_proxy);
            $('.internet-connected').text(data.internet_connected);
            $('.version').text(data.version);

            refreshServices(data);
        });
    };

    my.init = function () {
        my.loadData();

        $('#admin-submit').click(function () {
            changeAdmin({
                email: $('#email').val(),
                password: $('#password').val()
            });
        });

        $('#network-submit').click(function () {
            changeNetwork({
                name: 'eth0',
                ip_address: $('#ip_address').val(),
                netmask: $('#netmask').val(),
                gateway: $('#gateway').val(),
                nameservers: $('#nameservers').val().split(',')
                // TODO: is_dhcp
            });
        });

        $('#dhcp').change(function () {
            if (this.checked) {
                $('.static').prop('disabled', true);
            } else {
                $('.static').prop('disabled', false);
            }
        });

        $('#proxy-submit').click(function () {
            changeMicroCloud({ http_proxy: $('#proxy').val() });
        });

        $('#domain-submit').click(function () {
            changeDomain({
                name: $('#domain-name').val(),
                token: $('#token').val()
            });
        });
    };

    return my;
}(window, $));

$(document).ready(function () {
    "use strict";

    $(MCF.init);
});
