// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./AnimalsWorld.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AnimalsFight {

    AnimalsWorld animals;

    // mapping(address => AnimalsWorld) animalsOwner; // Needed if stake = 0 allowed
    mapping(uint256 => uint256) public readyToFight_Stake; // animalId => stake
    mapping(address => uint256) public stakeInContract;


    fallback () external payable {
        require(msg.value != 0);
        stakeInContract[msg.sender] += msg.value;
    }


    function readyToFight(uint256 animalId, uint256 _stake) public ownAnimal(animalId) {
        require(stakeInContract[msg.sender] >= _stake, "You need to send more ether than the stake to the contract first.");  // Can be removed to enable everybody to participate
        require(_stake > 0, "Your stake must be superior than 0 otherwise you can't participate.");                      // Can be removed to enable everybody to participate
        readyToFight_Stake[animalId] = _stake;
    }


    function agreeToFight(uint256 animalId, uint256 _opponent) public ownAnimal(animalId) { // opponent is an animal id
        require(readyToFight_Stake[_opponent] > 0, "Your opponent doesn't exist or havent placed any stake yet.");
        require(stakeInContract[msg.sender] >= readyToFight_Stake[_opponent], "You need to send more ether than the stake to the contract first.");
        fight(animalId, _opponent);
    }


    function fight(uint256 animalId_participant, uint256 animalId_proposer) public returns (string memory) {

        string memory returnedMessage;

        uint256 _loserAnimal; // id
        address _loserAddress;

        uint256 _winnerAnimal; // id
        address _winnerAddress;

        uint256 _stake = readyToFight_Stake[animalId_proposer];
        readyToFight_Stake[animalId_proposer] = 0; // reset the stake to 0 once the fight is over
        
        // DECLARE WINNER
        uint randWinner = animals.random();
        if (randWinner == 0) {
            // joiner won
            _loserAnimal = animalId_proposer;
            _winnerAnimal = animalId_participant;

            returnedMessage = string(abi.encodePacked("Congratulation, you won ", uint2str(_stake), " ether!"));
        } else {
            // proposer won
            _loserAnimal = animalId_participant;
            _winnerAnimal = animalId_proposer;
            
            returnedMessage = string(abi.encodePacked("Sorry, you were defeated and you animal died... OH and you've also lost ", uint2str(_stake), " ether x)"));
        }

        _loserAddress = animals.registerBreeder(_loserAnimal);
        _winnerAddress = animals.registerBreeder(_winnerAnimal);

        // TRANSFER ETHER
        stakeInContract[_loserAddress] -= _stake;
        stakeInContract[_winnerAddress] += _stake;
        // _transfer(address(this), _winnerAddress, _stake); // amount in wei ? commented since _transfer()-ERC20 could not work in erc721 contract

        // KILL ANIMAL
        AnimalsWorld loser = AnimalsWorld(_loserAddress);
        loser.deadAnimal(_loserAnimal); // Might not work if it is not called from the animal owner address

        return returnedMessage;
    }


    modifier ownAnimal(uint256 animalId) {
        require(animals.registerBreeder(animalId) == msg.sender, "You don't own this animal.");
        _;
    }
    

    // From https://github.com/provable-things/ethereum-api/blob/master/oraclizeAPI_0.5.sol
    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }
}