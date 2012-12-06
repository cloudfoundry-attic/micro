describe("initialize", function () {
  describe(".admin_submit", function () {
    var mcf;

    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="admin-submit" type="button" class="btn">Submit</button>' +
        '<div id="global-error" style="display: none"></div>' +
        '<input id="email" value="some_email"> ' +
        '<input id="password" value="some_password"> ' +
        '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="admin-bar"></div></div>'
      );
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
        $('#admin-submit').click();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      xit("re-enables the submit button", function () {
      });
    });
  });

  describe(".domain_submit", function () {
    var mcf;

    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="domain-submit" type="button" class="btn">Submit</button>' +
        '<div id="global-error" style="display: none"></div>' +
        '<input id="domain-name" value="some_name"> ' +
        '<input id="token" value="some_token"> ' +
        '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="domain-bar"></div></div>');
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
        $('#domain-submit').click();
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
    var mcf;

    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="internet-on-submit" type="button" class="btn">Submit</button>' +
        '<div id="global-error" style="display: none"></div>' +
        '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="internet-bar"></div></div>');
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
        $('#internet-on-submit').click();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      xit("re-enables the submit button", function () {
      });
    });
  });

  describe(".internet_off_submit", function () {
    var mcf;

    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="internet-off-submit" type="button" class="btn">Submit</button>' +
        '<div id="global-error" style="display: none"></div>' +
        '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="internet-bar"></div></div>');
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
        expect(mcf.update_micro_cloud).toHaveBeenCalledWith({ internet_connected: false }, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback) {
          callback();
        });
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
        $('#internet-off-submit').click();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      xit("re-enables the submit button", function () {
      });
    });
  });

  describe(".network_submit", function () {
    var mcf;

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
          name: "eth0",
          ip_address: "some_ip", 
          gateway: "some_gateway", 
          netmask: "some_netmask", 
          nameservers: ["first nameserver", "second nameserver"], 
          is_dhcp: true
          }, jasmine.any(Function), jasmine.any(Function));
      });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_network').andCallFake(function (data, callback) {
          callback();
        });
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
        $('#network-submit').click();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      xit("re-enables the submit button", function () {
      });
    });
  });

  describe(".network_submit", function () {
    var mcf;

    beforeEach(function () {
      $('#jasmine_content').html(
        '<button id="proxy-submit" type="button" class="btn">Submit</button>' +
        '<div id="global-error" style="display: none"></div>' +
        '<input id="proxy" value="some_proxy"> ' +
        '<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="proxy-bar"></div></div>');
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
        expect(mcf.update_micro_cloud).toHaveBeenCalledWith({ http_proxy: "some_proxy", }, jasmine.any(Function), jasmine.any(Function)); });
    });

    describe("when the updating is successful", function () {
      beforeEach(function () {
        spyOn(mcf, 'update_micro_cloud').andCallFake(function (data, callback) {
          callback();
        });
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
        $('#proxy-submit').click();
        expect(mcf.load_data).toHaveBeenCalled();
      });
    });

    describe("when the updating is a failure", function () {
      xit("re-enables the submit button", function () {
      });
    });
  });
});