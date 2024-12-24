// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/access/Ownable.sol";
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
import "./Strings.sol";
import "./Base64.sol";

contract AmeBadge is IComponent, Ownable {
    using Strings for uint256;

    uint256 public badgeIds;
    mapping(uint256 => Badge) public badges;
    mapping(address => mapping(uint256 => uint256)) public balance;
    mapping(uint256 => uint256) public mintedAmount;
    mapping(uint256 => address[]) public whiteList;

    mapping(address => uint256) public creatorIndexs;
    mapping(address => mapping(uint256 => uint256)) public creatorIndexBadgeIds;

    mapping(address => uint256) public userIndexs;
    mapping(address => mapping(uint256 => uint256)) public userIndexBadgeIds;
    

    struct Badge {
        string name;
        string description;
        string image;
        string data;
        uint256 category; //user mint, whitelist mint, award
        uint256 price; //0:free
        uint256 claimLimit; //0:no limit
        uint256 totalSupply; //0: no limit
        uint256 endDate; //0: no limit
        address creator;
    }

    mapping(string => Types.Type[]) methodRequests;
    mapping(string => Types.Type[]) methodResponses;
    mapping(MethodTypes => string[]) methods;

    constructor() Ownable() {
        Types.Type[] memory type1 = new Types.Type[](9);
        type1[0] = Types.Type.STRING;
        type1[1] = Types.Type.STRING;
        type1[2] = Types.Type.STRING;
        type1[3] = Types.Type.STRING;
        type1[4] = Types.Type.UINT256;
        type1[5] = Types.Type.UINT256;
        type1[6] = Types.Type.UINT256;
        type1[7] = Types.Type.UINT256;
        type1[8] = Types.Type.UINT256;

        Types.Type[] memory type2 = new Types.Type[](5);
        type2[0] = Types.Type.UINT256;
        type2[1] = Types.Type.STRING;
        type2[2] = Types.Type.STRING;
        type2[3] = Types.Type.STRING;
        type2[4] = Types.Type.STRING;

        Types.Type[] memory type3 = new Types.Type[](10);
        type3[0] = Types.Type.STRING;
        type3[1] = Types.Type.STRING;
        type3[2] = Types.Type.STRING;
        type3[3] = Types.Type.STRING;
        type3[4] = Types.Type.UINT256;
        type3[5] = Types.Type.UINT256;
        type3[6] = Types.Type.UINT256;
        type3[7] = Types.Type.UINT256;
        type3[8] = Types.Type.UINT256;
        type3[9] = Types.Type.ADDRESS;

        Types.Type[] memory type4 = new Types.Type[](1);
        type4[0] = Types.Type.UINT256;

        Types.Type[] memory type5 = new Types.Type[](2);
        type5[0] = Types.Type.ADDRESS;
        type5[1] = Types.Type.UINT256;

        Types.Type[] memory type6 = new Types.Type[](2);
        type6[0] = Types.Type.UINT256;
        type6[1] = Types.Type.ADDRESS_ARRAY;

        Types.Type[] memory type7 = new Types.Type[](1);
        type7[0] = Types.Type.ADDRESS_ARRAY;

        Types.Type[] memory type8 = new Types.Type[](3);
        type8[0] = Types.Type.ADDRESS;
        type8[1] = Types.Type.UINT256;
        type8[2] = Types.Type.UINT256;

        Types.Type[] memory type9 = new Types.Type[](1);
        type9[0] = Types.Type.STRING_ARRAY;

        Types.Type[] memory type10 = new Types.Type[](2);
        type10[0] = Types.Type.UINT256;
        type10[1] = Types.Type.ADDRESS;

        setMethod("addBadge", MethodTypes.POST, type1, new Types.Type[](0));
        setMethod("updateBadge", MethodTypes.PUT, type2, new Types.Type[](0));
        setMethod("getBadge", MethodTypes.GET, type4, type3);
        setMethod("getBalance", MethodTypes.GET, type5, type4);
        setMethod("addWhitelist", MethodTypes.POST, type6, new Types.Type[](0));
        setMethod("getWhiteList", MethodTypes.GET, type4, type7);
        setMethod("getMintedAmount", MethodTypes.GET, type4, type4);
        setMethod("getCreatorBadges", MethodTypes.GET, type8, type9);
        setMethod("mint", MethodTypes.POST, type10, new Types.Type[](0));
        setMethod("getUserBadges", MethodTypes.GET, type8, type9);
    }

    function get(string memory _methodName, bytes memory _methodReq)
        public
        view
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "getBadge")) {
            uint256 _badgeId = abi.decode(_methodReq, (uint256));

            if (_badgeId > badgeIds) {
                revert("badge does not exist");
            } else {
                Badge memory badge = badges[_badgeId];
                return
                    abi.encode(
                        badge.name,
                        badge.description,
                        badge.image,
                        badge.data,
                        badge.category,
                        badge.price,
                        badge.claimLimit,
                        badge.totalSupply,
                        badge.endDate,
                        badge.creator
                    );
            }
        } else if (compareStrings(_methodName, "getBalance")) {
            (address _account, uint256 _badgeId) = abi.decode(
                _methodReq,
                (address, uint256)
            );
            return abi.encode(balance[_account][_badgeId]);
        } else if (compareStrings(_methodName, "getCreatorBadges")) {
            (address _account, uint256 _pageNum, uint256 _pageSize) = abi
                .decode(_methodReq, (address, uint256, uint256));

            string[] memory creatorBadges = getCreatorBadges(
                _account,
                _pageNum,
                _pageSize
            );

            return abi.encode(creatorBadges);
        } else if (compareStrings(_methodName, "getUserBadges")) {
            (address _account, uint256 _pageNum, uint256 _pageSize) = abi
                .decode(_methodReq, (address, uint256, uint256));

            string[] memory userBadges = getUserBadges(
                _account,
                _pageNum,
                _pageSize
            );

            return abi.encode(userBadges);
        } else if (compareStrings(_methodName, "getMintedAmount")) {
            uint256 _badgeId = abi.decode(_methodReq, (uint256));
            return abi.encode(mintedAmount[_badgeId]);
        } else if (compareStrings(_methodName, "getWhiteList")) {
            uint256 _badgeId = abi.decode(_methodReq, (uint256));
            return abi.encode(whiteList[_badgeId]);
        } else {
            return abi.encode("");
        }
    }

    function post(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "addBadge")) {
            (
                string memory _name,
                string memory _description,
                string memory _image,
                string memory _data,
                uint256 _category,
                uint256 _price,
                uint256 _claimLimit,
                uint256 _totalSupply,
                uint256 _endDate
            ) = abi.decode(
                    _methodReq,
                    (
                        string,
                        string,
                        string,
                        string,
                        uint256,
                        uint256,
                        uint256,
                        uint256,
                        uint256
                    )
                );
            Badge memory badge = Badge(
                _name,
                _description,
                _image,
                _data,
                _category,
                _price,
                _claimLimit,
                _totalSupply,
                _endDate,
                msg.sender
            );
            badges[badgeIds] = badge;

            uint256 creatorIndex = creatorIndexs[msg.sender];
            creatorIndexBadgeIds[msg.sender][creatorIndex] = badgeIds;

            creatorIndexs[msg.sender] = creatorIndex + 1;
            badgeIds++;

            return abi.encode("");
        } else if (compareStrings(_methodName, "mint")) {
            (uint256 _badgeId, address _receiver) = abi.decode(
                _methodReq,
                (uint256, address)
            );
            mint(_badgeId, _receiver);
            return abi.encode("");
        } else if (compareStrings(_methodName, "addWhitelist")) {
            (uint256 _badgeId, address[] memory _accounts) = abi.decode(
                _methodReq,
                (uint256, address[])
            );
            Badge memory badge = badges[_badgeId];

            require(msg.sender == badge.creator);

            if (badge.category == 1) {
                for (uint256 i = 0; i < _accounts.length; i++) {
                    whiteList[_badgeId].push(_accounts[i]);
                }
            } else {
                revert("this badge is not a whitelist badge");
            }

            return abi.encode("");
        } else {
            return abi.encode("");
        }
    }

    function put(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "updateBadge")) {
            (
                uint256 _badgeId,
                string memory _name,
                string memory _description,
                string memory _image,
                string memory _data
            ) = abi.decode(
                    _methodReq,
                    (uint256, string, string, string, string)
                );

            require(badges[_badgeId].creator == msg.sender);
            badges[_badgeId].name = _name;
            badges[_badgeId].description = _description;
            badges[_badgeId].image = _image;
            badges[_badgeId].data = _data;

            return abi.encode("");
        } else {
            return abi.encode("");
        }
    }

    function getCreatorBadges(
        address _user,
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (string[] memory) {
        uint256 creatorIndex = creatorIndexs[_user];

        if (creatorIndex == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 &&
                ((creatorIndex - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (creatorIndex - 1) -
                    (_pageNum - 1) *
                    _pageSize;
                uint256 dataEnd;

                if (dataStart < _pageSize) {
                    dataEnd = 0;
                    arrayLength = dataStart + 1;
                } else {
                    dataEnd = dataStart - _pageSize + 1;
                    arrayLength = _pageSize;
                }

                string[] memory returnArray = new string[](arrayLength);

                for (int256 i = int256(dataStart); i >= int256(dataEnd); i--) {
                    uint256 badgeId = creatorIndexBadgeIds[_user][uint256(i)];

                    returnArray[arrayIndex] = generateBadgesBase64(
                        badgeId,
                        _user
                    );
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }

    function getUserBadges(
        address _user,
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (string[] memory) {
        uint256 userIndex = userIndexs[_user];

        if (userIndex == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 && ((userIndex - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (userIndex - 1) -
                    (_pageNum - 1) *
                    _pageSize;
                uint256 dataEnd;

                if (dataStart < _pageSize) {
                    dataEnd = 0;
                    arrayLength = dataStart + 1;
                } else {
                    dataEnd = dataStart - _pageSize + 1;
                    arrayLength = _pageSize;
                }

                string[] memory returnArray = new string[](arrayLength);

                for (int256 i = int256(dataStart); i >= int256(dataEnd); i--) {
                    uint256 badgeId = userIndexBadgeIds[_user][uint256(i)];

                    returnArray[arrayIndex] = generateBadgesBase64(
                        badgeId,
                        _user
                    );
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }

    function mint(uint256 _badgeId, address _receiver) internal {
        require(_badgeId < badgeIds);

        Badge memory badge = badges[_badgeId];

        //check price
  
        if(msg.value < badge.price){
            revert(
                "amount is less than badge price"
            );
        }else if(badge.price!=0 && msg.value>=badge.price){
            (bool success, ) = badge.creator.call{value: msg.value}("");
            require(success, "Transfer failed");
        }

        //check claim limit
        if (
            badge.claimLimit > 0 &&
            balance[_receiver][_badgeId] == badge.claimLimit
        ) {
            revert(
                "mint amount exceeds the max mintable amount for this account"
            );
        }

        //check totalSupply
        if (
            badge.totalSupply > 0 && mintedAmount[_badgeId] == badge.totalSupply
        ) {
            revert("exceeds maximum supply");
        }

        //check endDate
        if (badge.endDate > 0 && block.timestamp >= badge.endDate) {
            revert("exceeds mint date");
        }

        //add record
        if (balance[msg.sender][_badgeId] == 0) {
            uint256 userIndex = userIndexs[msg.sender];
            userIndexBadgeIds[msg.sender][userIndex] = _badgeId;
            userIndexs[msg.sender]++;
        }

        if (badge.category == 0) {
            require(msg.sender == _receiver);

            balance[msg.sender][_badgeId] = balance[msg.sender][_badgeId] + 1;

            mintedAmount[_badgeId]++;

          


        } else if (badge.category == 1) {
            require(msg.sender == _receiver);
            address[] memory addresses = whiteList[_badgeId];
            bool isWhiteList = false;
            for (uint256 i = 0; i < addresses.length; i++) {
                if (addresses[i] == msg.sender) {
                    isWhiteList = true;
                    break;
                }
            }

            if (isWhiteList) {
                balance[msg.sender][_badgeId] =
                    balance[msg.sender][_badgeId] +
                    1;
                mintedAmount[_badgeId]++;
            } else {
                revert("you are not whitelisted");
            }
  
        } else if (badge.category == 2) {
            require(msg.sender == badge.creator);
            balance[_receiver][_badgeId] = balance[_receiver][_badgeId] + 1;
            mintedAmount[_badgeId]++;
   
        } else {
            revert("badge category error");
        }
    }

    function generateBadgesBase64(uint256 _badgeId, address _user)
        public
        view
        returns (string memory)
    {
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"id": "',
                        _badgeId.toString(),
                        '", "name":"',
                        badges[_badgeId].name,
                        '","description":"',
                        badges[_badgeId].description,
                        '","image":"',
                        badges[_badgeId].image,
                        '","data":"',
                        badges[_badgeId].data,
                        '","balance":"',
                        balance[_user][_badgeId].toString(),
                        '"}'
                    )
                )
            )
        );
        string memory uri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return uri;
    }

    function options() public pure returns (MethodTypes[] memory) {
        MethodTypes[] memory methodTypes = new MethodTypes[](4);
        methodTypes[0] = MethodTypes.GET;
        methodTypes[1] = MethodTypes.POST;
        methodTypes[2] = MethodTypes.PUT;
        methodTypes[3] = MethodTypes.OPTIONS;
        return methodTypes;
    }

    function setMethod(
        string memory _methodName,
        MethodTypes _methodType,
        Types.Type[] memory _methodReq,
        Types.Type[] memory _methodRes
    ) private {
        methods[_methodType].push(_methodName);
        methodRequests[_methodName] = _methodReq;
        methodResponses[_methodName] = _methodRes;
    }

    function getMethodReqAndRes(string memory _methodName)
        public
        view
        returns (Types.Type[] memory, Types.Type[] memory)
    {
        return (methodRequests[_methodName], methodResponses[_methodName]);
    }

    function getMethods(MethodTypes _methodTypes)
        public
        view
        returns (string[] memory)
    {
        return methods[_methodTypes];
    }

    function compareStrings(string memory _a, string memory _b)
        private
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }
}
