describe("defaultTo is a helper", function() {
	it("returns a default value when a parameter is undefined", function() {
		expect(arm.defaultTo(undefined, 10)).toBe(10);
	});
	it("returns the value of the first parameter when it is set", function() {
		expect(arm.defaultTo("fish", 10)).toBe("fish");
	});
});