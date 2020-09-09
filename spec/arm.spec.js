import { expect } from 'chai';
import { defaultTo, plusify } from '../app/js/utils';

describe("defaultTo is a helper", () => {
	it("returns a default value when a parameter is undefined", () => {
		expect(defaultTo(undefined, 10)).to.equal(10);
	});
	it("returns a default value when a parameter is null", () => {
		expect(defaultTo(null, 10)).to.equal(10);
	});
	it("returns the value of the first parameter when it is set", () => {
		expect(defaultTo("fish", 10)).to.equal("fish");
	});
});

describe("plusify is a helper function", () => {
	it("Prepends the plus sign to a number", () => {
		expect(plusify(1)).to.equal("+1");
	});
	it("Except when the number is negative", () => {
		expect(plusify(-1)).to.equal(-1);
	});
});