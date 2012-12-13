describe("initialize", function () {
  var mcf;

  describe("#on_startup", function () {
    beforeEach(function () {
      $('#jasmine_content').html('<div id="configured">Configured Div</div><div id="not-configured">Not Configured Div</div>')
      jasmine.Ajax.useMock();
      mcf = new Mcf('/api');
      spyOn(mcf, 'load_data');
      initialize_micro_cloudfoundry(mcf);
    });

    it("should make an ajax request to check the configuration state", function () {
      var request = mostRecentAjaxRequest();
      expect(request.url).toEqual('/api');
      expect(request.method).toEqual('GET');
    });

    context("when configured", function () {
      it("displays the configured section", function () {
        expect($('#configured')).not.toBeVisible();
        expect($('#not-configured')).not.toBeVisible();
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        expect($('#configured')).toBeVisible();
        expect($('#not-configured')).not.toBeVisible();
      });

      it('should call load data', function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });


    context("when not configured", function () {
      it("displays the not configured section", function () {
        expect($('#configured')).not.toBeVisible();
        expect($('#not-configured')).not.toBeVisible();
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:false})});
        expect($('#configured')).not.toBeVisible();
        expect($('#not-configured')).toBeVisible();
      });

      it('should not call load data', function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:false})});
        expect(mcf.load_data).not.toHaveBeenCalled();
      });
    });
  });

  describe(".admin_submit", function () {
    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="admin-submit" type="button" class="btn">Submit</button>' +
          '<div id="global-error" style="display: none"></div>' +
          '<input id="email" value="some_email"> ' +
          '<input id="password" value="some_password"> ' +
          '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="admin-bar"></div></div>'
      );
      jasmine.Ajax.useMock();
      mcf = new Mcf('/api');
      initialize_micro_cloudfoundry(mcf);
    });

    describe("before the ajax request has returned", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_admin');
      });

      it("should shows a progress bar", function () {
        expect($('#admin-bar')).not.toBeVisible();
        $('#admin-submit').click();
        expect($('#admin-bar')).toBeVisible();
      });

      it("should disables the submit button", function () {
        expect($('#admin-submit')).not.toBeDisabled();
        $('#admin-submit').click();
        expect($('#admin-submit')).toBeDisabled();
      });

      it("should updates the users email and password", function () {
        $('#admin-submit').click();
        expect(mcf.update_admin).toHaveBeenCalledWith({email:"some_email", password:"some_password"}, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_admin').andCallFake(function (data, callback) {
          callback();
        });

        spyOn(mcf, 'configured');
        spyOn(mcf, 'load_data');
      });

      it("hides the bar", function () {
        $('#admin-submit').click();
        expect($('#admin-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#admin-submit').click();
        expect($('#admin-submit')).not.toBeDisabled();
      });

      it("loads the data", function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        $('#admin-submit').click();
        expect(mcf.configured).toHaveBeenCalled();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_admin').andCallFake(function (data, callback, error_callback) {
          error_callback();
        });
        spyOn(mcf, 'load_data');
      });

      it("shows an error alert", function () {
        $('#admin-submit').click();
        expect($('#global-error')).toBeVisible();
      });

      it("hides the bar", function () {
        $('#admin-submit').click();
        expect($('#domain-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#admin-submit').click();
        expect($('#domain-submit')).not.toBeDisabled();
      });

      it("does not reload the data", function () {
        $('#admin-submit').click();
        expect(mcf.load_data).not.toHaveBeenCalled();
      });
    });
  });

  describe(".domain_submit", function () {
    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="domain-submit" type="button" class="btn">Submit</button>' +
          '<div id="global-error" style="display: none"></div>' +
          '<input id="domain-name" value="some_name"> ' +
          '<input id="token" value="some_token"> ' +
          '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="domain-bar"></div></div>');
      jasmine.Ajax.useMock();
      mcf = new Mcf('/api');
      initialize_micro_cloudfoundry(mcf);
    });

    describe("before the ajax request has returned", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_domain');
      });

      it("should shows a progress bar", function () {
        expect($('#domain-bar')).not.toBeVisible();
        $('#domain-submit').click();
        expect($('#domain-bar')).toBeVisible();
      });

      it("should disables the submit button", function () {
        expect($('#domain-submit')).not.toBeDisabled();
        $('#domain-submit').click();
        expect($('#domain-submit')).toBeDisabled();
      });

      it("should updates the domains name and token", function () {
        $('#domain-submit').click();
        expect(mcf.update_domain).toHaveBeenCalledWith({name:"some_name", token:"some_token"}, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_domain').andCallFake(function (data, callback) {
          callback();
        });

        spyOn(mcf, 'configured');
        spyOn(mcf, 'load_data');
      });

      it("hides the bar", function () {
        $('#domain-submit').click();
        expect($('#domain-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#domain-submit').click();
        expect($('#domain-submit')).not.toBeDisabled();
      });

      it("loads the data", function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        $('#domain-submit').click();
        expect(mcf.configured).toHaveBeenCalled();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_domain').andCallFake(function (data, callback, error_callback) {
          error_callback();
        });
        spyOn(mcf, 'load_data');
      });

      it("shows an error alert", function () {
        $('#domain-submit').click();
        expect($('#global-error')).toBeVisible();
      });

      it("hides the bar", function () {
        $('#domain-submit').click();
        expect($('#domain-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#domain-submit').click();
        expect($('#domain-submit')).not.toBeDisabled();
      });

      it("does not reload the data", function () {
        $('#domain-submit').click();
        expect(mcf.load_data).not.toHaveBeenCalled();
      });

    });
  });

  describe(".internet_on_submit", function () {
    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="internet-on-submit" type="button" class="btn">Submit</button>' +
          '<div id="global-error" style="display: none"></div>' +
          '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="internet-bar"></div></div>');
      jasmine.Ajax.useMock();
      mcf = new Mcf('/api');
      initialize_micro_cloudfoundry(mcf);
    });

    describe("before the ajax request has returned", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud');
      });

      it("should shows a progress bar", function () {
        expect($('#internet-bar')).not.toBeVisible();
        $('#internet-on-submit').click();
        expect($('#internet-bar')).toBeVisible();
      });

      it("should disables the submit button", function () {
        expect($('#internet-on-submit')).not.toBeDisabled();
        $('#internet-on-submit').click();
        expect($('#internet-on-submit')).toBeDisabled();
      });

      it("should updates internet connected to true", function () {
        $('#internet-on-submit').click();
        expect(mcf.update_micro_cloud).toHaveBeenCalledWith({internet_connected:true}, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback) {
          callback();
        });

        spyOn(mcf, 'configured');
        spyOn(mcf, 'load_data');
      });

      it("hides the bar", function () {
        $('#internet-on-submit').click();
        expect($('#internet-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#internet-on-submit').click();
        expect($('#internet-on-submit')).not.toBeDisabled();
      });

      it("loads the data", function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        $('#internet-on-submit').click();
        expect(mcf.update_micro_cloud).toHaveBeenCalledWith({internet_connected:true}, jasmine.any(Function), jasmine.any(Function));

        expect(mcf.configured).toHaveBeenCalled();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback, error_callback) {
          error_callback();
        });
        spyOn(mcf, 'load_data');
      });

      it("shows an error alert", function () {
        $('#internet-on-submit').click();
        expect($('#global-error')).toBeVisible();
      });

      it("hides the bar", function () {
        $('#internet-on-submit').click();
        expect($('#internet-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#internet-on-submit').click();
        expect($('#internet-on-submit')).not.toBeDisabled();
      });

      it("does not reload the data", function () {
        $('#internet-on-submit').click();
        expect(mcf.load_data).not.toHaveBeenCalled();
      });
    });
  });

  describe(".internet_off_submit", function () {
    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="internet-off-submit" type="button" class="btn">Submit</button>' +
          '<div id="global-error" style="display: none"></div>' +
          '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="internet-bar"></div></div>');
      jasmine.Ajax.useMock();
      mcf = new Mcf('/api');
      initialize_micro_cloudfoundry(mcf);
    });

    describe("before the ajax request has returned", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud');
      });

      it("should shows a progress bar", function () {
        expect($('#internet-bar')).not.toBeVisible();
        $('#internet-off-submit').click();
        expect($('#internet-bar')).toBeVisible();
      });

      it("should disables the submit button", function () {
        expect($('#internet-off-submit')).not.toBeDisabled();
        $('#internet-off-submit').click();
        expect($('#internet-off-submit')).toBeDisabled();
      });

      it("should updates internet internet_connected to false", function () {
        $('#internet-off-submit').click();
        expect(mcf.update_micro_cloud).toHaveBeenCalledWith({ internet_connected:false }, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback) {
          callback();
        });
        spyOn(mcf, 'configured');
        spyOn(mcf, 'load_data');
      });

      it("hides the bar", function () {
        $('#internet-off-submit').click();
        expect($('#internet-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#internet-off-submit').click();
        expect($('#internet-off-submit')).not.toBeDisabled();
      });

      it("loads the data", function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        $('#internet-off-submit').click();
        expect(mcf.configured).toHaveBeenCalled();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback, error_callback) {
          error_callback();
        });
        spyOn(mcf, 'load_data');
      });

      it("shows an error alert", function () {
        $('#internet-off-submit').click();
        expect($('#global-error')).toBeVisible();
      });

      it("hides the bar", function () {
        $('#internet-off-submit').click();
        expect($('#internet-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#internet-off-submit').click();
        expect($('#internet-off-submit')).not.toBeDisabled();
      });

      it("does not reload the data", function () {
        $('#internet-off-submit').click();
        expect(mcf.load_data).not.toHaveBeenCalled();
      });
    });
  });

  describe(".network_submit", function () {
    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="network-submit" type="button" class="btn">Submit</button>' +
          '<div id="global-error" style="display: none"></div>' +
          '<input id="ip-address" value="some_ip"> ' +
          '<input id="gateway" value="some_gateway"> ' +
          '<input id="netmask" value="some_netmask"> ' +
          '<input id="nameservers" value="first nameserver,second nameserver"> ' +
          '<input type="checkbox" id="dhcp" checked> ' +
          '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="network-bar"></div></div>');
      jasmine.Ajax.useMock();
      mcf = new Mcf('/api');
      initialize_micro_cloudfoundry(mcf);
    });

    describe("before the ajax request has returned", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_network');
      });

      it("should shows a progress bar", function () {
        expect($('#network-bar')).not.toBeVisible();
        $('#network-submit').click();
        expect($('#network-bar')).toBeVisible();
      });

      it("should disables the submit button", function () {
        expect($('#network-submit')).not.toBeDisabled();
        $('#network-submit').click();
        expect($('#network-submit')).toBeDisabled();
      });

      it("should updates network config", function () {
        $('#network-submit').click();
        expect(mcf.update_network).toHaveBeenCalledWith({
          name:"eth0",
          ip_address:"some_ip",
          gateway:"some_gateway",
          netmask:"some_netmask",
          nameservers:["first nameserver", "second nameserver"],
          is_dhcp:true
        }, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_network').andCallFake(function (data, callback) {
          callback();
        });
        spyOn(mcf, 'configured');
        spyOn(mcf, 'load_data');
      });

      it("hides the bar", function () {
        $('#network-submit').click();
        expect($('#network-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#network-submit').click();
        expect($('#network-submit')).not.toBeDisabled();
      });

      it("loads the data", function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        $('#network-submit').click();
        expect(mcf.configured).toHaveBeenCalled();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_network').andCallFake(function (data, callback, error_callback) {
          error_callback();
        });
        spyOn(mcf, 'load_data');
      });

      it("shows an error alert", function () {
        $('#network-submit').click();
        expect($('#global-error')).toBeVisible();
      });

      it("hides the bar", function () {
        $('#network-submit').click();
        expect($('#network-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#internet-off-submit').click();
        expect($('#network-submit')).not.toBeDisabled();
      });

      it("does not reload the data", function () {
        $('#network-submit').click();
        expect(mcf.load_data).not.toHaveBeenCalled();
      });
    });
  });

  describe(".proxy_submit", function () {
    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="proxy-submit" type="button" class="btn">Submit</button>' +
          '<div id="global-error" style="display: none"></div>' +
          '<input id="proxy" value="some_proxy"> ' +
          '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="proxy-bar"></div></div>');
      jasmine.Ajax.useMock();
      mcf = new Mcf('/api');
      initialize_micro_cloudfoundry(mcf);
    });

    describe("before the ajax request has returned", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud');
      });

      it("should shows a progress bar", function () {
        expect($('#proxy-bar')).not.toBeVisible();
        $('#proxy-submit').click();
        expect($('#proxy-bar')).toBeVisible();
      });

      it("should disables the submit button", function () {
        expect($('#proxy-submit')).not.toBeDisabled();
        $('#proxy-submit').click();
        expect($('#proxy-submit')).toBeDisabled();
      });

      it("should updates network config", function () {
        $('#proxy-submit').click();
        expect(mcf.update_micro_cloud).toHaveBeenCalledWith({ http_proxy:"some_proxy"}, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback) {
          callback();
        });
        spyOn(mcf, 'configured');
        spyOn(mcf, 'load_data');
      });

      it("hides the bar", function () {
        $('#proxy-submit').click();
        expect($('#proxy-bar')).not.toBeVisible();
      });

      it("re-enables the submit button", function () {
        $('#proxy-submit').click();
        expect($('#proxy-submit')).not.toBeDisabled();
      });

      it("loads the data", function () {
        mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
        $('#proxy-submit').click();
        expect(mcf.configured).toHaveBeenCalled();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });
  });

  describe("when the updating is a failure", function () {
    beforeEach(function () {
      spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback, error_callback) {
        error_callback();
      });
      spyOn(mcf, 'load_data');
    });

    it("shows an error alert", function () {
      $('#proxy-submit').click();
      expect($('#global-error')).toBeVisible();
    });

    it("hides the bar", function () {
      $('#proxy-submit').click();
      expect($('#proxy-bar')).not.toBeVisible();
    });

    it("re-enables the submit button", function () {
      $('#proxy-submit').click();
      expect($('#proxy-submit')).not.toBeDisabled();
    });

    it("does not reload the data", function () {
      $('#proxy-submit').click();
      expect(mcf.load_data).not.toHaveBeenCalled();
    });
  });
});

describe(".initial_submit", function () {
  beforeEach(function () {
    $('#jasmine_content').html(
      '<div id="global-error" style="display: none"></div>' +
        '<form>' +
        '<input type="password" id="initial-password" value="password">' +
        '<input type="radio" id="initial-domain-public" name="domain" checked>' +
        '<input type="radio" id="initial-domain-private" name="domain">' +
        '<input type="text" id="initial-domain-token" value="token">' +
        '<input type="text" id="initial-domain-offline" value="domain">' +
        '<input type="email" id="initial-email" value="email">' +
        '<input type="radio" id="initial-network-dhcp" name="network">' +
        '<input type="radio" id="initial-network-static" name="network" checked>' +
        '<input type="text" id="initial-ip-address" class="static" value="ip">' +
        '<input type="text" id="initial-netmask" class="static" value="netmask">' +
        '<input type="text" id="initial-gateway" class="static" value="gateway">' +
        '<input type="text" id="initial-nameservers" class="static" value="nameservers">' +
        '<button type="button" class="btn" id="initial-submit">Submit</button>' +
        '<div class="bar" style="width: 0%;" id="initial-bar"></div>' +
        '</form>');
    jasmine.Ajax.useMock();
    mcf = new Mcf('/api');
    initialize_micro_cloudfoundry(mcf);
  });

  describe("before the ajax request has returned", function () {
    beforeEach(function () {
      spyOn(mcf, 'initial_config');
    });

    it("should shows a progress bar", function () {
      expect($('#initial-bar')).not.toBeVisible();
      $('#initial-submit').click();
      expect($('#initial-bar')).toBeVisible();
    });

    it("should disables the submit button", function () {
      expect($('#initial-submit')).not.toBeDisabled();
      $('#initial-submit').click();
      expect($('#initial-submit')).toBeDisabled();
    });

    it("should updates network config", function () {
      $('#initial-submit').click();
      expect(mcf.initial_config).toHaveBeenCalledWith({
        password:"password",
        token:"token",
        ip:"ip",
        netmask:"netmask",
        gateway:"gateway",
        nameservers:"nameservers",
        is_dhcp:false
      }, jasmine.any(Function), jasmine.any(Function));
    });

    context("when the user choose dhcp and public", function () {
      beforeEach(function () {
        $('#initial-network-dhcp').click();
      });

      it("should updates network config", function () {
        $('#initial-submit').click();
        expect(mcf.initial_config).toHaveBeenCalledWith({
          password:"password",
          token:"token",
          is_dhcp:true
        }, jasmine.any(Function), jasmine.any(Function));
      });
    });

    context("when the user chooses private domain and static", function () {
      beforeEach(function () {
        $('#initial-domain-private').click();
      });

      it("should updates network config", function () {
        $('#initial-submit').click();
        expect(mcf.initial_config).toHaveBeenCalledWith({
          password:"password",
          name:"domain",
          email:"email",
          ip:"ip",
          netmask:"netmask",
          gateway:"gateway",
          nameservers:"nameservers",
          is_dhcp:false
        }, jasmine.any(Function), jasmine.any(Function));
      });
    });
  });

  describe("when the updating is successful", function () {
    beforeEach(function () {
      spyOn(mcf, 'initial_config').andCallFake(function (data, callback) {
        callback();
      });
      spyOn(mcf, 'configured');
      spyOn(mcf, 'load_data');
    });

    it("hides the bar", function () {
      $('#initial-submit').click();
      expect($('#initial-bar')).not.toBeVisible();
    });

    it("re-enables the submit button", function () {
      $('#initial-submit').click();
      expect($('#initial-submit')).not.toBeDisabled();
    });

    it("loads the data", function () {
      mostRecentAjaxRequest().response({status:200, responseText:JSON.stringify({is_configured:true})});
      $('#initial-submit').click();
      expect(mcf.configured).toHaveBeenCalled();
      expect(mcf.load_data).toHaveBeenCalled();
    });
  });

  describe("when the updating is a failure", function () {
    beforeEach(function () {
      spyOn(mcf, 'initial_config').andCallFake(function (data, callback, error_callback) {
        error_callback();
      });
      spyOn(mcf, 'load_data');
    });

    it("shows an error alert", function () {
      $('#initial-submit').click();
      expect($('#global-error')).toBeVisible();
    });

    it("hides the bar", function () {
      $('#initial-submit').click();
      expect($('#proxy-bar')).not.toBeVisible();
    });

    it("re-enables the submit button", function () {
      $('#initial-submit').click();
      expect($('#initial-submit')).not.toBeDisabled();
    });

    it("does not reload the data", function () {
      $('#initial-submit').click();
      expect(mcf.load_data).not.toHaveBeenCalled();
    });
  });

  describe("accordion toggles", function () {

    beforeEach(function () {
      $('#jasmine_content').html(
        '<a class="accordion-toggle" id="a"><input type="radio" id="radio" </a>'
      );

      initialize_micro_cloudfoundry(mcf);
    });

    it("checks child radios", function () {
      var spyEvent = spyOnEvent('#radio', 'click');

      expect($('#radio')).not.toBeChecked();
      $('#a').click();
      expect($('#radio')).toBeChecked();
    });

    it("becomes checked when clicked", function () {
      var spyEvent = spyOnEvent('#radio', 'click');

      expect($('#radio')).not.toBeChecked();
      $('#radio').click();
      expect($('#radio')).toBeChecked();
    });

  });

});
