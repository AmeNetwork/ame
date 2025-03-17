### Name
Ame Feed

### Description
A simple text content publishing component.

### Author
[Rickey](https://github.com/HelloRickey)

### Specification

***
```GET``` ***getContentIds***

Responses
- ```uint256``` latest content id

***

```GET``` ***getContent***  
Parameters
- ```uint256``` content id

Responses 
- ```string``` content detail
- ```address``` content publisher 

***

```GET``` ***getUserContentIndex***  
Parameters
- ```address``` user address

Responses 
- ```uint256``` latest index of user content 

***

```GET``` ***getContentIdByAddress***  
Parameters
- ```address``` user address
- ```uint256``` content index

Responses 
- ```uint256``` content id

***

```POST``` ***createContent***  
Parameters
- ```string``` content detail
***

### Network

| Chain | Address |
| ----------- | ----------- |
| OP Sepolia  | 0xdAE4c5cbE7a90C6f4533C9e6EFE75532051b8651 |
| Base Sepolia | 0xdAE4c5cbE7a90C6f4533C9e6EFE75532051b8651 |
| Zora Sepolia   | 0xdAE4c5cbE7a90C6f4533C9e6EFE75532051b8651 |
| OpBNB  | 0xdAE4c5cbE7a90C6f4533C9e6EFE75532051b8651 |
| Redstone Holysky  | 0xd2120C981fA39E67B75426510f5Efc21Cb0abB28 |
| Cyber Testnet  | 0xAFAcad0039eE54C31b0f6E44186a8113A3531334 |