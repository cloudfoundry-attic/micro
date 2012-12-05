describe("Util", function () {
  describe(".leading_zero_pad", function () {
    it("doesn't do anything if the number is long enough", function () {
      expect(util.leading_zero_pad(42, 1)).toEqual("42")
    });

    it("pads things that are too short", function () {
      expect(util.leading_zero_pad(42, 3)).toEqual("042")
    });
  });
});
