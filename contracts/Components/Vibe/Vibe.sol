// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/access/Ownable.sol";
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
import "./Strings.sol";
import "./Base64.sol";

contract VibeComponent is IComponent, Ownable {
    using Strings for uint256;

    uint256 public vibeIds;
    string[] categories;

    mapping(string => Types.Type[]) methodRequests;
    mapping(string => Types.Type[]) methodResponses;
    mapping(MethodTypes => string[]) methods;

    struct Vibe {
        uint256 vibeId;
        string vibeContent;
        address user;
    }

    event NewVibe(uint256 indexed _vibeId,string indexed  _vibeContent,address indexed  _user);
    event DeleteVibe(uint256 indexed _vibeId);

    mapping(uint256 => Vibe) public Vibes;
    mapping(address => uint256) public UserVibeIndexs;
    mapping(address => mapping(uint256 => uint256)) public UserVibeIds;

    mapping(string => uint256) public VibeCategoryIndexs;
    mapping(string => mapping(uint256 => uint256)) public VibeCategoryIds;

    uint256 public FeaturedIndexs;
    mapping(uint256 => uint256) public FeaturedIds;

    mapping(address => bool) public BlackList;

    constructor() Ownable() {
        Types.Type[] memory type1 = new Types.Type[](1);
        type1[0] = Types.Type.ADDRESS;

        Types.Type[] memory type2 = new Types.Type[](1);
        type2[0] = Types.Type.UINT256;

        Types.Type[] memory type3 = new Types.Type[](1);
        type3[0] = Types.Type.STRING_ARRAY;

        Types.Type[] memory type4 = new Types.Type[](4);
        type4[0] = Types.Type.STRING_ARRAY;
        type4[1] = Types.Type.STRING;
        type4[2] = Types.Type.STRING;
        type4[3] = Types.Type.ADDRESS;

        Types.Type[] memory type5 = new Types.Type[](2);
        type5[0] = Types.Type.UINT256;
        type5[1] = Types.Type.BOOL;

        Types.Type[] memory type6 = new Types.Type[](2);
        type6[0] = Types.Type.UINT256;
        type6[1] = Types.Type.UINT256;

        Types.Type[] memory type7 = new Types.Type[](3);
        type7[0] = Types.Type.STRING;
        type7[1] = Types.Type.UINT256;
        type7[2] = Types.Type.UINT256;

        Types.Type[] memory type8 = new Types.Type[](3);
        type8[0] = Types.Type.ADDRESS;
        type8[1] = Types.Type.UINT256;
        type8[2] = Types.Type.UINT256;

        Types.Type[] memory type9 = new Types.Type[](3);
        type9[0] = Types.Type.UINT256;
        type9[1] = Types.Type.STRING;
        type9[2] = Types.Type.ADDRESS;

        Types.Type[] memory type10 = new Types.Type[](2);
        type10[0] = Types.Type.ADDRESS;
        type10[1] = Types.Type.BOOL;

        setMethod("setFeatured", MethodTypes.PUT, type6, new Types.Type[](0));

        setMethod("postVibe", MethodTypes.POST, type4, type2);

        setMethod("deleteVibe", MethodTypes.PUT, type2, new Types.Type[](0));

        setMethod("addFeatured", MethodTypes.POST, type2, new Types.Type[](0));

        setMethod("getVibe", MethodTypes.GET, type2, type9);

        setMethod("getVibes", MethodTypes.GET, type6, type3);

        setMethod("getVibeIdByFeaturedIndex", MethodTypes.GET, type2, type2);

        setMethod("getVibesByCategory", MethodTypes.GET, type7, type3);

        setMethod("getVibesByAddress", MethodTypes.GET, type8, type3);

        setMethod("getVibesByFeatured", MethodTypes.GET, type6, type3);

        setMethod("setBlacklist", MethodTypes.PUT, type10, new Types.Type[](0));

        setMethod("isBlacklist", MethodTypes.GET, type1, type10);
    }

    function get(string memory _methodName, bytes memory _methodReq)
        public
        view
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "getVibe")) {
            uint256 _vibeId = abi.decode(_methodReq, (uint256));
            return
                abi.encode(
                    _vibeId,
                    Vibes[_vibeId].vibeContent,
                    Vibes[_vibeId].user
                );
        } else if (compareStrings(_methodName, "getVibes")) {
            (uint256 _pageNum, uint256 _pageSize) = abi.decode(
                _methodReq,
                (uint256, uint256)
            );
            string[] memory vibes = getVibes(_pageNum, _pageSize);
            return abi.encode(vibes);
        } else if (compareStrings(_methodName, "getVibesByCategory")) {
            (string memory _category, uint256 _pageNum, uint256 _pageSize) = abi
                .decode(_methodReq, (string, uint256, uint256));
            string[] memory vibes = getVibesByCategory(
                _category,
                _pageNum,
                _pageSize
            );
            return abi.encode(vibes);
        } else if (compareStrings(_methodName, "getVibesByAddress")) {
            (address _user, uint256 _pageNum, uint256 _pageSize) = abi.decode(
                _methodReq,
                (address, uint256, uint256)
            );
            string[] memory vibes = getVibesByAddress(
                _user,
                _pageNum,
                _pageSize
            );
            return abi.encode(vibes);
        } else if (compareStrings(_methodName, "getVibesByFeatured")) {
            (uint256 _pageNum, uint256 _pageSize) = abi.decode(
                _methodReq,
                (uint256, uint256)
            );
            string[] memory vibes = getVibesByFeatured(_pageNum, _pageSize);
            return abi.encode(vibes);
        } else if (compareStrings(_methodName, "getVibeIdByFeaturedIndex")) {
            uint256 _featuredIndex = abi.decode(_methodReq, (uint256));
            return abi.encode(FeaturedIds[_featuredIndex]);
        } else if (compareStrings(_methodName, "isBlacklist")) {
            address _user = abi.decode(_methodReq, (address));
            return abi.encode(_user, BlackList[_user]);
        } else {
            return abi.encode("");
        }
    }

    function post(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
        require(!BlackList[msg.sender]);
        if (compareStrings(_methodName, "postVibe")) {
            (
                string[] memory _vibeCategories,
                string memory _vibeContent,
                string memory _resources,
                address _user
            ) = abi.decode(_methodReq, (string[], string, string,address));
            uint256 currentVibeId = vibeIds;

            address postUser=msg.sender;    
            if(msg.sender==owner()){
                postUser=_user;
            }

                
            string memory vibeContent = generateBase64(
                currentVibeId,
                _vibeCategories,
                _vibeContent,
                _resources,
                postUser
            );

            Vibe memory vibe = Vibe(currentVibeId, vibeContent, postUser);

            Vibes[currentVibeId] = vibe;
            UserVibeIds[postUser][UserVibeIndexs[postUser]] = currentVibeId;

            for (uint256 i = 0; i < _vibeCategories.length; i++) {
                VibeCategoryIds[_vibeCategories[i]][
                    VibeCategoryIndexs[_vibeCategories[i]]
                ] = currentVibeId;
                VibeCategoryIndexs[_vibeCategories[i]]++;
            }

            UserVibeIndexs[postUser]++;

            emit Response(abi.encode(vibeIds));
            emit NewVibe(currentVibeId, vibeContent, postUser);

            vibeIds++;

            return abi.encode(currentVibeId);
        } else if (compareStrings(_methodName, "addFeatured")) {
            require(msg.sender == owner());
            uint256 _vibeId = abi.decode(_methodReq, (uint256));
            FeaturedIds[FeaturedIndexs] = _vibeId;
            FeaturedIndexs++;
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
        if (compareStrings(_methodName, "deleteVibe")) {
            uint256 _vibeId = abi.decode(_methodReq, (uint256));
            require(msg.sender == Vibes[_vibeId].user || msg.sender==owner());
            string[] memory _vibeCategories=new string[](0);
            Vibes[_vibeId].vibeContent = generateBase64(
                _vibeId,
                _vibeCategories,
                "",
                "",
                Vibes[_vibeId].user
            );
            emit DeleteVibe(_vibeId);
            return abi.encode("");
        } else if (compareStrings(_methodName, "setFeatured")) {
            require(msg.sender == owner());
            (uint256 _featruedIndex, uint256 _vibeId) = abi.decode(
                _methodReq,
                (uint256, uint256)
            );
            FeaturedIds[_featruedIndex] = _vibeId;
            return abi.encode("");
        } else if (compareStrings(_methodName, "setBlacklist")) {
            require(msg.sender == owner());
            (address _user, bool _isBlack) = abi.decode(
                _methodReq,
                (address, bool)
            );
            BlackList[_user] = _isBlack;
            return abi.encode("");
        } else {
            return abi.encode("");
        }
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

    function getVibes(uint256 _pageNum, uint256 _pageSize)
        public
        view
        returns (string[] memory)
    {
        if (vibeIds == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (_pageNum > 1 && ((vibeIds - 1) / _pageSize) < (_pageNum - 1)) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (vibeIds - 1) - (_pageNum - 1) * _pageSize;
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
                    returnArray[arrayIndex] = Vibes[uint256(i)].vibeContent;
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }

    function getVibesByAddress(
        address _user,
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (string[] memory) {
        uint256 userVibeIndex = UserVibeIndexs[_user];

        if (userVibeIndex == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 &&
                ((userVibeIndex - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (userVibeIndex - 1) -
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
                    uint256 vibeId = UserVibeIds[_user][uint256(i)];
                    returnArray[arrayIndex] = Vibes[vibeId].vibeContent;
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }

    function getVibesByCategory(
        string memory _categoryId,
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (string[] memory) {
        uint256 userCategoryContentIds = VibeCategoryIndexs[_categoryId];
        if (userCategoryContentIds == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 &&
                ((userCategoryContentIds - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (userCategoryContentIds - 1) -
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
                    uint256 contentId = VibeCategoryIds[_categoryId][
                        uint256(i)
                    ];
                    returnArray[arrayIndex] = Vibes[contentId].vibeContent;
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }

    function getVibesByFeatured(uint256 _pageNum, uint256 _pageSize)
        public
        view
        returns (string[] memory)
    {
        if (FeaturedIndexs == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 &&
                ((FeaturedIndexs - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (FeaturedIndexs - 1) -
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
                    uint256 contentId = FeaturedIds[uint256(i)];
                    returnArray[arrayIndex] = Vibes[contentId].vibeContent;
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }

    function compareStrings(string memory _a, string memory _b)
        private
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    function generateBase64(
        uint256 _vibeId,
        string[] memory _vibeCategories,
        string memory _vibeContent,
        string memory _resources,
        address _user
    ) public view returns (string memory) {

        bytes memory encodeStr;
        for (uint256 i = 0; i < _vibeCategories.length; i++) {
            if(i==0){
                encodeStr=abi.encodePacked(Base64.encode(bytes(_vibeCategories[i])));
            }else{
               encodeStr=abi.encodePacked(encodeStr, ",", Base64.encode(bytes(_vibeCategories[i])));
            }
       
        }
        return
            string(
                abi.encodePacked(
                    _vibeId.toString(),
                    ",",
                    Base64.encode(encodeStr),
                    ",",
                    Base64.encode(bytes(_vibeContent)),
                    ",",
                    Base64.encode(bytes(_resources)),
                    ",",
                    Strings.toHexString(uint256(uint160(_user)), 20),
                    ",",
                    block.timestamp.toString()
                )
            );
    }
}
