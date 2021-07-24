1. [Presentation](#presentation)
2. [Functions and code review](#function)
    1. [My animal](#animal)
    2. [Fighting and betting](#fight)
3. [Migration and deployment](#migration)

# Presentation <a name="presentation"></a>

This smart contract aims to create an animal type **NFT** with various properties. 2 contracts are deployed, [one](contracts/AnimalsWorld.sol) allows the creation of this nft and methods associated with it, the [second](contracts/AnimalsFight.sol) is a separate contract allowing the owner of animals to fight against others by placing a bet in **ether**.

The installation of the openzeppelin library ```npm install @openzeppelin/contracts```, simplifies the development of smart-contracts thanks to the integration of ERC standards and their direct use.

```solidity
// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract AnimalsWorld is ERC721 {

    address owner;

    constructor() public ERC721("AnimalsWorld", "ANMW") {
        owner = msg.sender;
    }
}
```

Thanks to the import of the file *ERC721.sol* from openzeppelin's library we were able to create in a few lines our first contract that generates nft **AnimalsWorld** with the ticker '**ANMW**'.

# Functions and code review <a name="function"></a>

## My animal <a name="animal"></a>

Anyone can use the contract to create his own *animal* for which the characteristics are stored in a mapping of the kind ```mapping(uint256 => animalStruct) public animalCharacteristic``` that associates the structure of an animal with its identifier. Similarly each animal *identifier* is mapped to the *address* of its owner in the ***registerBreeder*** mapping.

The function for creating an animal is the following one :

```solidity
function declareAnimal(string memory animalName, string memory gender, uint8 age, uint8 wingsNumber, uint8 legsNumber, uint8 eyesNumber)
        public
        returns (uint256)
{
    require(age > 0 && wingsNumber > 0 && legsNumber > 0 && eyesNumber > 0, "Age, wings, legs or eyes number must be superior or equal than 0.");
    require(keccak256(abi.encode(gender)) == "male" || keccak256(abi.encode(gender)) == "femele", "Gender is undefined, please chose between 'male' or 'femele'.");

    _tokenIds.increment();

    uint256 newAnimalId = _tokenIds.current();
    _mint(msg.sender, newAnimalId);

    registerBreeder[newAnimalId] = msg.sender;

    animalStruct memory newAnimal = animalStruct(animalName, gender, age, wingsNumber, legsNumber, eyesNumber);
    animalCharacteristic[newAnimalId] = newAnimal;

    return newAnimalId;
}
```

The owner of an animal can decide to kill it with ```deadAnimal(uint256 animalId)``` by burning it :cry:. It is then necessary to remove the address and the attributes in the mapping.

If someone owns 2 animals of different genders it is possible via the method ```breedAnimal(string memory newAnimalName, uint256 animal_one, uint256 animal_two)``` to mate them in order to obtain a new animal of random sexe and of 0 years old (which is obvious) with characteristics inherited from both parents.

Of course these functions can only be called by the owner. That's why a **modifier** ***onlyAnimalOwner*** checks that the address making the call for a given animal really owns it by simply looking in the ***registerBreeder***.

## Fighting and betting <a name="fight"></a>

Since being able to kill your own animal is not funny enough, thanks to this [second contract](contracts/AnimalsFight.sol) we will be able to make it fight against the animal of another player in a death match with a stake :smiling_imp: (just kidding, animals extreme defenders please don't pick on me).

Each contestant has to stake some ethers in the contract to be able to compete, this prevents from betting a specific amount of money and then transferring it back to their address just before the fight in order to avoid paying the winner. A ```fallback ()``` function is used to receive these ethers and to avoid going through the whole blockchain to know who sent how much, it is then listed in a new ***stakeInContract*** mapping.

Thanks to the function ```readyToFight(uint256 animalId, uint256 _stake)```, any owner of an animal can declare it ready to fight and stake on it an amount less than or equal to the number of ether they have staked in the contract. The id of the animal and its stake are also listed in a mapping *id => stake* ***readyToFight_Stake***.

A second player can join a fight by calling ```agreeToFight(uint256 animalId, uint256 _opponent)``` and declare the animal he would like to fight against the one declared by another player beforehand (by entering the IDs), the bid for both participants will then be the one registered in ***readyToFight_Stake***. By accepting to join a match this function will automatically execute ```fight()``` and take as parameters the two identifiers and will randomly return a winner. The losing animal will unfortunately perish and the loser's stake will then be awarded to the winner but still within the contract by updating the address funds in the ***stakeInContract*** mapping.

ideally we should create a method that would enable a player to retrieve their stakes funds that also include their winnings. However the function ```_transfer()``` in an erc721 contract does not support sending ethers but only nft.

# Migration and deployment <a name="migration"></a>

See https://github.com/lth-elm/erc20-ico#migration.