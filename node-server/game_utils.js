function generateDeck() {
    var deck = []
    var num_suits = 4
    var num_values = 13
    var n_indexed = 1    
    for (let i = 0; i < num_suits; i++){
        for (let j = 0; j < num_values; j++){
            deck.push(`${i+n_indexed}-${j+n_indexed}`)
        }
    }
    return deck
}

function shuffleDeck(deck) {
    // Durstenfeld/Knuth shuffle
    for (let i = deck.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [deck[i], deck[j]] = [deck[j], deck[i]];
    }
    return deck
}
// references:
//// https://stackoverflow.com/questions/2450954/how-to-randomize-shuffle-a-javascript-array
//// https://blog.codinghorror.com/the-danger-of-naivete/

function generateHands(deck=shuffleDeck(generateDeck()), num_players=4, num_cards=13, hands = {}) {
    console.log(deck)
    if (Object.keys(hands).length === 0) {
        for (let i = 0; i < num_players; i++) {
            hands[`${i}`] = []
        }
    }

    for (let i = 0; i < num_cards; i++) {
        Object.keys(hands).forEach(j => hands[j].push(deck.shift()))
    }

    console.log(hands)
    return hands
}

exports.generateHands = generateHands