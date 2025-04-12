// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract Blackjack {
    enum GameState { NONE, PLAYER_TURN, DEALER_TURN, COMPLETE }

    struct Game {
        address player;
        uint8[] playerCards;
        uint8[] dealerCards;
        GameState state;
        uint256 bet;
    }

    mapping(address => Game) public games;

    event GameStarted(address indexed player, uint8[4] cards);
    event PlayerHit(address indexed player, uint8 card);
    event PlayerStand(address indexed player);
    event GameResult(address indexed player, string result, uint256 payout);

    function startGame() external payable {
        require(msg.value > 0, "Bet required");
        Game storage game = games[msg.sender];
        require(game.state == GameState.NONE || game.state == GameState.COMPLETE, "Finish previous game");

        delete game.playerCards;
        delete game.dealerCards;

        uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender)));
        uint8[4] memory cards = [
            toCard(seed),
            toCard(seed + 1),
            toCard(seed + 2),
            toCard(seed + 3)
        ];

        game.player = msg.sender;
        game.bet = msg.value;
        game.playerCards.push(cards[0]);
        game.playerCards.push(cards[1]);
        game.dealerCards.push(cards[2]);
        game.dealerCards.push(cards[3]);
        game.state = GameState.PLAYER_TURN;

        emit GameStarted(msg.sender, cards);

        if (handValue(game.playerCards) == 21) {
            uint256 payout = (game.bet * 3) / 2;
            payable(msg.sender).transfer(payout);
            game.state = GameState.COMPLETE;
            emit GameResult(msg.sender, "Blackjack!", payout);
        }
    }

    function hit() external {
        Game storage game = games[msg.sender];
        require(game.state == GameState.PLAYER_TURN, "Not your turn");
        uint8 card = toCard(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, game.playerCards.length))));
        game.playerCards.push(card);
        emit PlayerHit(msg.sender, card);

        if (handValue(game.playerCards) > 21) {
            game.state = GameState.COMPLETE;
            emit GameResult(msg.sender, "Bust", 0);
        }
    }

    function stand() external {
        Game storage game = games[msg.sender];
        require(game.state == GameState.PLAYER_TURN, "Not your turn");
        game.state = GameState.DEALER_TURN;
        emit PlayerStand(msg.sender);

        while (handValue(game.dealerCards) < 17) {
            uint8 card = toCard(uint256(keccak256(abi.encodePacked(block.timestamp, msg.sender, game.dealerCards.length))));
            game.dealerCards.push(card);
        }

        uint8 playerScore = handValue(game.playerCards);
        uint8 dealerScore = handValue(game.dealerCards);

        string memory result;
        uint256 payout = 0;

        if (dealerScore > 21 || playerScore > dealerScore) {
            payout = game.bet * 2;
            result = "Player wins";
        } else if (playerScore == dealerScore) {
            payout = game.bet;
            result = "Push";
        } else {
            result = "Dealer wins";
        }

        if (payout > 0) {
            payable(msg.sender).transfer(payout);
        }

        game.state = GameState.COMPLETE;
        emit GameResult(msg.sender, result, payout);
    }

    function handValue(uint8[] memory cards) internal pure returns (uint8 total) {
        uint8 aces = 0;
        for (uint i = 0; i < cards.length; i++) {
            total += cards[i];
            if (cards[i] == 11) aces++;
        }
        while (total > 21 && aces > 0) {
            total -= 10;
            aces--;
        }
    }

    function toCard(uint256 rand) internal pure returns (uint8) {
        uint8 val = uint8(rand % 13 + 1);
        if (val >= 10) return 10;
        if (val == 1) return 11;
        return val;
    }
}
