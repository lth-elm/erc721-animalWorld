// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract AnimalsWorld is ERC721 {

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    address owner;
    uint private randNonce = 3; // init for no reason at 3

    struct animalStruct {
        string animalName;
        string gender;
        uint8 age;
        uint8 wingsNumber;
        uint8 legsNumber;
        uint8 eyesNumber;
    }

    mapping(uint256 => address) public registerBreeder; // each unique item (animal) belongs to an address
    mapping(uint256 => animalStruct) public animalCharacteristic;


    constructor() public ERC721("AnimalsWorld", "ANMW") {
        owner = msg.sender;
    }


    // Anyone can create his own animal
    function declareAnimal(string memory animalName, string memory gender, uint8 age, uint8 wingsNumber, uint8 legsNumber, uint8 eyesNumber)
        public
        returns (uint256)
    {
        require(age > 0 && wingsNumber > 0 && legsNumber > 0 && eyesNumber > 0, "Age, wings, legs or eyes number must be superior or equal than 0.");
        require(keccak256(abi.encode(gender)) == "male" || keccak256(abi.encode(gender)) == "femele", "Gender is undefined, please chose between 'male' or 'femele'.");

        _tokenIds.increment();

        uint256 newAnimalId = _tokenIds.current();
        _mint(msg.sender, newAnimalId);
        // _setTokenURI(newAnimalId, tokenURI);

        registerBreeder[newAnimalId] = msg.sender;

        animalStruct memory newAnimal = animalStruct(animalName, gender, age, wingsNumber, legsNumber, eyesNumber);
        animalCharacteristic[newAnimalId] = newAnimal;

        return newAnimalId;
    }


    function deadAnimal(uint256 animalId) public onlyAnimalOwner(animalId) {
        _burn(animalId);
        registerBreeder[animalId] = address(0);
        delete animalCharacteristic[animalId];
    }


    // Create an animal by mixing two existing one and their characteristics
    function breedAnimal(string memory newAnimalName, uint256 animal_one, uint256 animal_two) 
        public 
        returns (uint256) 
    {
        require (registerBreeder[animal_one] == msg.sender && registerBreeder[animal_two] == msg.sender, "One or both of the animals doesn't belong to you.");
        require (keccak256(abi.encode(animalCharacteristic[animal_one].gender)) != keccak256(abi.encode(animalCharacteristic[animal_two].gender)), "Animals can't have the same gender to breed.");

        _tokenIds.increment();

        uint256 newAnimalId = _tokenIds.current();
        _mint(msg.sender, newAnimalId);
        // _setTokenURI(newAnimalId, tokenURI);

        registerBreeder[newAnimalId] = msg.sender;

        string memory newGender;

        if (random() == 0) {
            newGender = "male";
        } else {
            newGender = "femele";
        }
        
        uint8 newWingsNumber = (animalCharacteristic[animal_one].wingsNumber + animalCharacteristic[animal_two].wingsNumber) / 2;
        uint8 newLegsNumber = (animalCharacteristic[animal_one].legsNumber + animalCharacteristic[animal_two].legsNumber) / 2;
        uint8 newEyesNumber = (animalCharacteristic[animal_one].eyesNumber + animalCharacteristic[animal_two].eyesNumber) / 2;

        animalStruct memory newAnimal = animalStruct(newAnimalName, newGender, 0, newWingsNumber, newLegsNumber, newEyesNumber);
        animalCharacteristic[newAnimalId] = newAnimal;

        return newAnimalId;
    }


    function random() public returns (uint) {
        randNonce++;
        uint _random = uint(keccak256(abi.encodePacked(block.timestamp, msg.sender, randNonce)));
        return _random % 2;
    } 


    modifier onlyAnimalOwner(uint256 animalId) { 
        require (registerBreeder[animalId] == msg.sender, "You don't own this animal."); // also imply that it exist
        _;
    }
}