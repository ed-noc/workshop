const generatePizza = require('./pizza');

test('Normal pizza to contain tomato sauce', () => {
    expect(generatePizza()).toEqual(
        expect.arrayContaining(['Tomato sauce']),
    );
});

test('Pizza bianca no to contain tomato sauce', () => {
    expect(generatePizza({ isBianca: true })).not.toEqual(
        expect.arrayContaining(['Tomato sauce']),
    );
});
