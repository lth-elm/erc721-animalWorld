1. [Présentation](#presentation)
2. [Fonctions et revue de code](#fonction)
    1. [Mon animal](#animal)
    2. [Combat et mise](#combat)
3. [Migration et déploiement](#migration)

# Présentation <a name="presentation"></a>

Ce smart contract a pour but la création d'un **NFT** de type animal avec différentes charactéristiques. 2 contrats sont déployés, l'[un](contracts/AnimalsWorld.sol) permet en partie la création de cette nft et de méthodes qui lui sont associés, le [second](contracts/AnimalsFight.sol) est un contrat à part permettant aux possesseur d'animaux et de les faire se combattre contre d'autres en plaçant une mise en ether.

L'installation de la librairie openzeppelin ```npm install @openzeppelin/contracts```, permet de simplifier le développement des smart-contracts grâce à l'intégration des standards ERC et leur utilisation direct.

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

Grâce à l'import du fichier *ERC721.sol* de la librairie d'openzeppelin on a pu en quelque ligne créer notre premier contrat générant des nft **AnimalsWorld** dont le ticker est '**ANMW**'.

# Fonctions et revue de code <a name="fonction"></a>

## Mon animal <a name="animal"></a>

Toute personne peut en faisant appel au contrat créer son propre *animal* dont les charactéristiques sont enregistrés dans un mapping de la sorte ```mapping(uint256 => animalStruct) public animalCharacteristic``` qui associent la structure d'un animal à son identifiant. De la même manière chaque *identifiant* d'animal est associé à l'*adresse* de son possesseur dans un mapping ```registerBreeder```.

La fonction permettant de créer son animal est la suivante :

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

Le détenteur d'un animal peut décider de le tuer avec ```deadAnimal()``` en burnant :cry:. Il faut alors aussi penser à supprimer l'adresse et les characteristiques dans le mapping.

Si une personne possède 2 animaux de sexes différents il peut alors via la méthode ```breedAnimal()``` les accoupler afin d'obtenir un nouvel animal agé de 0 année (logique), de charactéristiques héritant des deux parents et de sexes aléatoires.

Bien sûr ces fonctions ne doivent pouvoir être appelé que par le possesseur. C'est pour celà qu'un **modifier** ```onlyAnimalOwner``` vérifie que l'adresse faisant un appel pour un animal donnée le possède bien et ce, en regardant tout simplement dans le ```registerBreeder```.

## Combat et mise <a name="combat"></a>

Comme le fait de pouvoir tuer son animal soit même n'est pas assez drôle, on va pouvoir grâce à ce second contrat le faire affronter l'animal d'un autre joueur dans un match a mort avec mise :smiling_imp: (Je rigole les défenseurs extrêmiste me tomber pas dessus svp).

// EXPLIQUER LE FONCTIONNEMENT ICI

.....

# Migration et déploiement <a name="migration"></a>

Voir https://github.com/lth-elm/erc20-ico#migration.