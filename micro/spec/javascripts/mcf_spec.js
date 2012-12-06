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
      mcf.load_data();
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
});

//beforeEach(function () {
//  from_root_response = {_links: {administrator: {href: "/", method: "GET", type: 'text/json'}}};
//  admin_response = {_links: {edit: {href: "/", method: "GET", type: 'text/json'}}};
//
//  clearAjaxRequests();
//  $('#admin-submit').click();
//});
//
//it("hides the bar", function () {
//
//  expect($('#admin-bar')).toBeVisible();
//  ajaxRequests[0].response({status: 200, responseText: JSON.stringify(from_root_response)});
//  ajaxRequests[1].response({status: 200, responseText: JSON.stringify(admin_response)});
//  ajaxRequests[2].response({status: 200, responseText: '{}'});
//  expect($('#admin-bar')).not.toBeVisible();
//});
