describe("ProgressBar", function () {
  describe(".start_indeterminate", function () {
    var progress_bar;

    beforeEach(function () {
      $('#jasmine_content').html('<div class="progress progress-striped active"><div class="bar" style="width: 0;" id="internet-bar"></div></div>');
      progress_bar = new ProgressBar($('#internet-bar'));
    });

    it("should have progress set to 100%", function () {
      expect($('#internet-bar').width()).toEqual(0);
      progress_bar.start_indeterminate();
      expect($('#internet-bar').width()).toBeGreaterThan(100);
    });

    it("should be visible", function () {
      expect($('#internet-bar')).not.toBeVisible();
      progress_bar.start_indeterminate();
      expect($('#internet-bar')).toBeVisible();
    });
  });
});