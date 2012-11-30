describe(".leading_zero_pad", function () {
    it("doesn't do anything if the number is long enough", function () {
        expect(util.leading_zero_pad(42, 1)).toEqual("42")
    });

    it("pads things that are too short", function () {
        expect(util.leading_zero_pad(42, 3)).toEqual("042")
    });
});

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
            request.response({status:  500, responseText: ""});

            expect($('#global-error')).toBeVisible();
        });

    });
});

describe("Services", function () {
   describe("stopping", function() {
       var mcf;
       beforeEach(function () {
           mcf = new Mcf;
       });

        it("should gray out the button", function () {
            $('#jasmine_content').html('<a href="#" id="button_foosvc" class="btn btn-danger"><i class="icon-stop"></i> Stop</a>');

            var last_service = $('#jasmine_content a:last-child');
            //var unbindSpy = jasmine.createSpy('foo');  // can be used anywhere
            spyOn($.fn, 'unbind');

            last_service.click(function() { mcf.toggle_service("foosvc", true); });
            last_service.click();
            expect(last_service.attr('class')).toEqual("btn");
            expect($.fn.unbind).toHaveBeenCalled();
            expect($.fn.unbind.mostRecentCall.object.id).toEqual(last_service.id);
            expect(last_service.text()).toEqual("Pending")
       });
   });
});
