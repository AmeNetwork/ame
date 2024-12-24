// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/access/Ownable.sol";
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
import "./Strings.sol";
import "./Base64.sol";

contract VibeComment is IComponent, Ownable {
    using Strings for uint256;

    mapping(MethodTypes => string[]) methods;

    //@dev Types contains all data types in solidity
    mapping(string => Types.Type[]) methodRequests;
    mapping(string => Types.Type[]) methodResponses;

    uint256 public commentIds;
    mapping(uint256 => uint256) VibeCommentIndexs;
    mapping(address => uint256) UserCommentIndexs;

    mapping(uint256 => mapping(uint256 => uint256)) VibeCommentIds;
    mapping(address => mapping(uint256 => uint256)) UserIndexCommentIds;
    mapping(uint256 => Comment) Comments;

    event NewComment(uint256 indexed _vibeId,uint256 indexed _commentId,string _encodeComment,address indexed  _user);
    event DeleteComment(uint256 indexed _vibeId,uint256 indexed _commentId);

    struct Comment {
        uint256 vibeId;
        uint256 commentId;
        string content;
        address user;
    }

    constructor() Ownable() {
        Types.Type[] memory type1 = new Types.Type[](3);
        type1[0] = Types.Type.UINT256;
        type1[1] = Types.Type.STRING;
        type1[2] = Types.Type.STRING;

        Types.Type[] memory type2 = new Types.Type[](1);
        type2[0] = Types.Type.UINT256;

        Types.Type[] memory type3 = new Types.Type[](4);
        type3[0] = Types.Type.UINT256;
        type3[1] = Types.Type.UINT256;
        type3[2] = Types.Type.STRING;
        type3[3] = Types.Type.ADDRESS;

        Types.Type[] memory type4 = new Types.Type[](3);
        type4[0] = Types.Type.UINT256;
        type4[1] = Types.Type.UINT256;
        type4[2] = Types.Type.UINT256;

        Types.Type[] memory type5 = new Types.Type[](1);
        type5[0] = Types.Type.STRING_ARRAY;

        Types.Type[] memory type6 = new Types.Type[](3);
        type6[0] = Types.Type.ADDRESS;
        type6[1] = Types.Type.UINT256;
        type6[2] = Types.Type.UINT256;

        setMethod("postComment", MethodTypes.POST, type1, new Types.Type[](0));
        setMethod("deleteComment", MethodTypes.POST, type2, new Types.Type[](0));
        setMethod("getComment", MethodTypes.GET, type2, type3);
        setMethod("getComments", MethodTypes.GET, type4, type5);
        setMethod("getCommentsByAddress", MethodTypes.GET, type6, type5);
    }

    function get(string memory _methodName, bytes memory _methodReq)
        public
        view
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "getComment")) {
            uint256 _commentId = abi.decode(_methodReq, (uint256));
            Comment memory comment = Comments[_commentId];
            return
                abi.encode(
                    comment.vibeId,
                    comment.commentId,
                    comment.content,
                    comment.user
                );
        } else if (compareStrings(_methodName, "getComments")) {
            (uint256 _vibeId, uint256 _pageNum, uint256 _pageSize) = abi.decode(
                _methodReq,
                (uint256, uint256, uint256)
            );
            string[] memory tempArray = getComments(_vibeId, _pageNum, _pageSize);
            return abi.encode(tempArray);
        } else if (
            compareStrings(_methodName, "getCommentsByAddress")
        ) {
            (address _user, uint256 _pageNum, uint256 _pageSize) = abi.decode(
                _methodReq,
                (address, uint256, uint256)
            );
            string[] memory tempArray = getCommentsByAddress(_user, _pageNum, _pageSize);
            return abi.encode(tempArray);

        } else {
            return abi.encode("");
        }
    }

    function post(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "postComment")) {


            (uint256 _vibeId, string memory _content,string memory _resources) = abi
                .decode(_methodReq, (uint256, string,string));

            string memory encodeComment = generateBase64(
                _vibeId,
                commentIds,
                _content,
                _resources,
                msg.sender
            );

            uint256 vibeCommentIndex = VibeCommentIndexs[_vibeId];
            uint256 userCommentIndex = UserCommentIndexs[msg.sender];

            emit NewComment(_vibeId, commentIds, encodeComment,msg.sender);

            Comments[commentIds] = Comment(
                _vibeId,
                commentIds,
                encodeComment,
                msg.sender
            );
            VibeCommentIds[_vibeId][vibeCommentIndex] = commentIds;
            UserIndexCommentIds[msg.sender][userCommentIndex] = commentIds;

            VibeCommentIndexs[_vibeId]++;
            UserCommentIndexs[msg.sender]++;
            commentIds++;

         

            return abi.encode("");
        } else if(compareStrings(_methodName, "deleteComment")){
            
            (uint256 _commentId) = abi
                .decode(_methodReq, (uint256));
            
            Comment memory _comment=Comments[_commentId];

            require(_comment.user==msg.sender||msg.sender==owner());
            
            string memory encodeComment = generateBase64(
                _comment.vibeId,
                _commentId,
                "",
                "",
                _comment.user
            );

            Comments[_commentId].content=encodeComment;

            emit DeleteComment(_comment.vibeId,_commentId);

            return abi.encode("");
        }else {
            return abi.encode("");
        }
    }

    function put(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
        return abi.encode(_methodName, _methodReq);
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

    //@dev compares two strings for equality
    function compareStrings(string memory _a, string memory _b)
        private
        pure
        returns (bool)
    {
        return
            keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    function getComments(
        uint256 _vibeId,
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (string[] memory) {
        if (VibeCommentIndexs[_vibeId] == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 &&
                ((VibeCommentIndexs[_vibeId] - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (VibeCommentIndexs[_vibeId] - 1) -
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
                    uint256 commentId=VibeCommentIds[_vibeId][uint256(i)];
                    returnArray[arrayIndex] = Comments[commentId].content;
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }


    function getCommentsByAddress(
        address _user,
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (string[] memory) {
        if (UserCommentIndexs[_user] == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 &&
                ((UserCommentIndexs[_user] - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (UserCommentIndexs[_user] - 1) -
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
                    uint256 commentId=UserIndexCommentIds[_user][uint256(i)];
                    returnArray[arrayIndex] = Comments[commentId].content;
                    arrayIndex++;
                }
                return returnArray;
            }
        }
    }

    function generateBase64(
        uint256 _vibeId,
        uint256 _commentId,
        string memory _content,
        string memory _resources,
        address _user
    ) public view returns (string memory) {
        return
            string(
                abi.encodePacked(
                    _vibeId.toString(),
                    ",",
                    _commentId.toString(),
                    ",",
                    Base64.encode(bytes(_content)),
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
