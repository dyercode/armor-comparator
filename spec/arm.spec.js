import { expect } from 'chai';
import { numericSort, asc, desc } from '../src/Demo.bs';
import { totalMaxDex } from '../src/Calculations.bs';
import { plusify, defaultTo } from '../src/Demo.bs'


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
		expect(plusify(-1)).to.equal('-1');
	});
});

describe('totalMaxDex', () => {
	const armory = {
		armor: 0,
		maxDex: 3,
		cost: 0,
		comfortable: false,
		mithral: false,
		selectedEnhancement: undefined

	}
	it('is the raw value when not mithral', () => {
		expect(totalMaxDex(armory)).to.equal(armory.maxDex);
	})

	it('is inclreased by 2 for mithral', () => {
		expect(totalMaxDex({ ...armory, mithral: true })).to.equal(armory.maxDex + 2);
	})
})


describe('numericSort acts as a numeric comparator', () => {
	describe('can be ascending', () => {
		it('greater left number must be 1', () => {
			expect(numericSort(2, 1, asc)).to.equal(1)
		})
		it('lesser left number must be -1', () => {
			expect(numericSort(1, 2, asc)).to.equal(-1)
		})
		it('equal numbers must be 0', () => {
			expect(numericSort(1, 1, asc)).to.equal(0)
		})
	})

	describe('can be set to descending', () => {
		it('greater left number must be -1', () => {
			expect(numericSort(2, 1, desc)).to.equal(-1)
		})
		it('lesser left number must be 1', () => {
			expect(numericSort(1, 2, desc)).to.equal(1)
		})
		it('equal numbers must be 0', () => {
			expect(numericSort(1, 1, desc)).to.equal(0)
		})
	})
})