import { expect } from 'chai';
import { defaultTo, plusify, numericSort, DESC } from '../app/js/utils';

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


describe('numericSort acts as a numeric comparator', () => {
	describe('defaulting to ascending', () => {
		it('greater left number must be 1', () => {
			expect(numericSort(2, 1)).to.equal(1)
		})
		it('lesser left number must be -1', () => {
			expect(numericSort(1, 2)).to.equal(-1)
		})
		it('equal numbers must be 0', () => {
			expect(numericSort(1, 1)).to.equal(0)
		})
	})

	describe('can be set to descending', () => {
		it('greater left number must be -1', () => {
			expect(numericSort(2, 1, DESC)).to.equal(-1)
		})
		it('lesser left number must be 1', () => {
			expect(numericSort(1, 2, DESC)).to.equal(1)
		})
		it('equal numbers must be 0', () => {
			expect(numericSort(1, 1)).to.equal(0)
		})
	})
})