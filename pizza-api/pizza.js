function generatePizza({ isBianca = false } = {}) {
    /**
     * This function generates a random pizza for you.
     * 
     * You can specify, if you want a pizza bianca (white pizza without tomato sauce).
     * Your pizza will always include sourdough and mozzarella and 3 random toppings.
     */

    const toppings = ['Onion', 'Corn', 'Pineapple', 'Prosciutto', 'Artichoke', 'Olives', 'Egg', 'Cremini', 'Salami', 'Bacon'];
    const ingredients = ['Sourdough', 'Mozarella'];
    
    if (!isBianca) ingredients.push('Tomato sauce');
    
    return ingredients.concat(toppings
        .map(value => ({ value, sort: Math.random() }))
        .sort((a, b) => a.sort - b.sort)
        .map(({ value }) => value)
        .slice(0, 3));
}

module.exports = generatePizza;
