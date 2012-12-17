describe("Mcf", function () {
  describe(".load_data", function () {
    var mcf;

    beforeEach(function () {
      mcf = new Mcf;
    });

    it("should show an error div if the ajax request fails", function () {
      $('#jasmine_content').html("<div id='global-error'></div>");
      expect($('#global-error')).not.toBeVisible();
      jasmine.Ajax.useMock();
      mcf.configured();
      request = mostRecentAjaxRequest();
      request.response({status:500, responseText:""});

      expect($('#global-error')).toBeVisible();
    });

  });

  describe(".toggle_service", function () {
    var mcf;
    beforeEach(function () {
      mcf = new Mcf;
    });

    it("should gray out the button", function () {
      $('#jasmine_content').html('<a href="#" id="button_foosvc" class="btn btn-danger"><i class="icon-stop"></i> Stop</a>');

      var last_service = $('#jasmine_content a:last-child');
      //var unbindSpy = jasmine.createSpy('foo');  // can be used anywhere
      spyOn($.fn, 'unbind');

      last_service.click(function () {
        mcf.toggle_service("foosvc", true);
      });
      last_service.click();
      expect(last_service.attr('class')).toEqual("btn");
      expect($.fn.unbind).toHaveBeenCalled();
      expect($.fn.unbind.mostRecentCall.object.id).toEqual(last_service.id);
      expect(last_service.text()).toEqual("Pending")
    });
  });

  describe(".initial_config", function() {
    var mcf;

    beforeEach(function() {
      mcf = new Mcf;
    });

    it("configures the administrator", function() {
      spyOn(mcf, 'update_admin');

      spyOn(mcf, 'update_network').andCallFake(function (data, callback, error_callback) {
        callback();
      });

      mcf.initial_config({foo: 'bar', password: 'password', email: 'email@email.com'});
      expect(mcf.update_admin).toHaveBeenCalledWith({password: 'password', email: 'email@email.com'}, jasmine.any(Function));
    });

    it("configures the domain", function() {
      spyOn(mcf, 'update_domain');

      spyOn(mcf, 'update_network').andCallFake(function (data, callback, error_callback) {
        callback();
      });

      spyOn(mcf, 'update_admin').andCallFake(function (data, callback, error_callback) {
        callback();
      });

      mcf.initial_config({foo: 'bar', name: 'domain', token: 'token'});

      expect(mcf.update_domain).toHaveBeenCalledWith({name: 'domain', token: 'token'}, jasmine.any(Function));
    });

    it("configures the network", function() {
      spyOn(mcf, 'update_network');

      mcf.initial_config({foo: 'bar', ip_address: 'ip_address', netmask: 'netmask', gateway: "gateway", nameservers: "nameservers", is_dhcp: false});
      expect(mcf.update_network).toHaveBeenCalledWith({ip_address: 'ip_address', netmask: 'netmask', gateway: "gateway", nameservers: "nameservers", is_dhcp: false}, jasmine.any(Function));
    });

    context("when an error occurs", function() {
    });

  });
});
