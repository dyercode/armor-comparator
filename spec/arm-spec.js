describe("defaultTo is a helper", function() {
	it("returns a default value when a parameter is undefined", function() {
		expect(arm.defaultTo(undefined, 10)).toBe(10);
	});
	it("returns a default value when a parameter is null", function() {
		expect(arm.defaultTo(null, 10)).toBe(10);
	});
	it("returns the value of the first parameter when it is set", function() {
		expect(arm.defaultTo("fish", 10)).toBe("fish");
	});
});

describe("plusify is a helper function", function() {
	it("Prepends the plus sign to a number", function() {
		expect(arm.plusify(1)).toBe("+1");
	});
	it("Except when the number is negative", function() {
		expect(arm.plusify(-1)).toBe(-1);
	});
});