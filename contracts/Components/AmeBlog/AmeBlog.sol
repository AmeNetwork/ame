// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";

contract AmeFeed is IComponent {

    address owner;

    struct Topic {
        uint256 topicId;
        string topicName;
        string topicDescribe;
        string topicImage;
        bytes others;
    }

    struct Content {
        bytes content;
        bytes others;
        address user;
    }

    uint256 topicIds;
    mapping(uint256=>Topic) Topics;

    mapping(uint256 => uint256) ContentIds;
    mapping(uint256 => mapping(uint256=>Content)) Contents;
    mapping(address => mapping(uint256 =>uint256)) UserContentIds;
    mapping(address => mapping(uint256 => mapping(uint256 =>uint256))) UserContents;

    mapping(string => Types.Type[]) methodRequests;
    mapping(string => Types.Type[]) methodResponses;
    mapping(MethodTypes => string[]) methods;

    constructor() {
        owner=msg.sender;

        Types.Type[] memory type1 = new Types.Type[](1);
        type1[0] = Types.Type.UINT256;

        Types.Type[] memory type2 = new Types.Type[](2);
        type2[0] = Types.Type.UINT256;
        type2[1] = Types.Type.UINT256;

        Types.Type[] memory type3 = new Types.Type[](3);
        type3[0] = Types.Type.BYTES;
        type3[1] = Types.Type.BYTES;
        type3[2] = Types.Type.ADDRESS;

        Types.Type[] memory type4 = new Types.Type[](2);
        type4[0] = Types.Type.ADDRESS;
        type4[1] = Types.Type.UINT256;

        Types.Type[] memory type5 = new Types.Type[](3);
        type5[0] = Types.Type.ADDRESS;
        type5[1] = Types.Type.UINT256;
        type5[2] = Types.Type.UINT256;

        Types.Type[] memory type6 = new Types.Type[](3);
        type6[0] = Types.Type.UINT256;
        type6[1] = Types.Type.BYTES;
        type6[2] = Types.Type.BYTES;

        Types.Type[] memory type7 = new Types.Type[](4);
        type7[0] = Types.Type.STRING;
        type7[1] = Types.Type.STRING;
        type7[2] = Types.Type.STRING;
        type7[3] = Types.Type.BYTES;

        Types.Type[] memory type8 = new Types.Type[](5);
        type8[0] = Types.Type.UINT256;
        type8[1] = Types.Type.STRING;
        type8[2] = Types.Type.STRING;
        type8[3] = Types.Type.STRING;
        type8[4] = Types.Type.BYTES;



        setMethod(
            "getContentIds",
            MethodTypes.GET,
            type1,
            type1
        );
        setMethod(
            "getContent",
            MethodTypes.GET,
            type2,
            type3
        );
        setMethod(
            "getUserContentIndex",
            MethodTypes.GET,
            type4,
            type1
        );

        setMethod(
            "getContentIdByAddress",
            MethodTypes.GET,
            type5,
            type1
        );

        setMethod(
            "createContent",
            MethodTypes.POST,
            type6,
            new Types.Type[](0)
        );

        setMethod(
            "createTopic",
            MethodTypes.POST,
            type7,
            new Types.Type[](0)
        );

        setMethod(
            "setTopic",
            MethodTypes.PUT,
            type8,
            new Types.Type[](0)
        );

        setMethod(
            "getTopicIds",
            MethodTypes.GET,
            new Types.Type[](0),
            type1
        );

        setMethod(
            "getTopic",
            MethodTypes.GET,
            type1,
            type8
        );
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

    function get(string memory _methodName, bytes memory _methodReq)
        public
        view
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "getContentIds")) {
            return abi.encode(ContentIds[abi.decode(_methodReq, (uint256))]);
        } else if (compareStrings(_methodName, "getContent")) {
            (uint256 topicId,uint256 contentId)= abi.decode(_methodReq, (uint256,uint256));
            (bytes memory userContent,bytes memory others, address user) = getContent(topicId,contentId);
            return abi.encode(userContent,others,user);
        } else if (compareStrings(_methodName, "getUserContentIndex")) {

            (address user,uint256 topicId)=abi.decode(_methodReq, (address,uint256));
            uint256 userContentIndex= getUserContentIndex(user,topicId);
            return abi.encode(userContentIndex);

        } else if (compareStrings(_methodName, "getContentIdByAddress")) {
            (address user, uint256 topicId,uint256 contentIndex) = abi.decode(
                _methodReq,
                (address, uint256,uint256)
            );
            uint256 contentId = getContentIdByAddress(user,topicId, contentIndex);
            return abi.encode(contentId);
        }else if(compareStrings(_methodName, "getTopicIds")){
            return abi.encode(topicIds);
        }else if(compareStrings(_methodName, "getTopic")){

            uint256 topicId=abi.decode(_methodReq, (uint256));
            Topic memory topic=Topics[topicId];
            return abi.encode(topic.topicId,topic.topicName,topic.topicDescribe,topic.topicImage,topic.others);

        } else {
            return abi.encode("");
        }
    }

    function post(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "createTopic")) {
            require(msg.sender==owner);
            (
                string memory topicName,
                string memory topicDescribe,
                string memory topicImage,
                bytes memory others
            ) = abi.decode(_methodReq, (string, string, string, bytes));

            Topic memory topic = Topic(
                topicIds,
                topicName,
                topicDescribe,
                topicImage,
                others
            );

            Topics[topicIds]=topic;

            topicIds++;
          
        } else if (compareStrings(_methodName, "createContent")) {
            (uint256 topicId,bytes memory content ,bytes memory others)= abi.decode(_methodReq, (uint256,bytes,bytes));
            createContent(topicId,content,others);
        }
        return abi.encode("");
    }

    function put(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
         if (compareStrings(_methodName, "setTopic")) {
            require(msg.sender==owner);
            (   uint256 topicId,
                string memory topicName,
                string memory topicDescribe,
                string memory topicImage,
                bytes memory others
            ) = abi.decode(_methodReq, (uint256,string, string, string, bytes));

            Topics[topicId]=Topic(
                topicId,
                topicName,
                topicDescribe,
                topicImage,
                others
            );

        }else if(compareStrings(_methodName, "setContent")){

            (uint256 topicId,uint256 contentId,bytes memory newContent,bytes memory newOthers)=abi.decode(_methodReq, (uint256,uint256,bytes,bytes));

            Content memory content=Contents[topicId][contentId];

            require(msg.sender==content.user);

            Contents[topicId][contentId]=Content(newContent,newOthers,msg.sender);

        }
         return abi.encode("");
    }

    function options() public pure returns (MethodTypes[] memory) {
        MethodTypes[] memory methodTypes = new MethodTypes[](3);
        methodTypes[0] = MethodTypes.GET;
        methodTypes[1] = MethodTypes.POST;
        methodTypes[2] = MethodTypes.OPTIONS;
        return methodTypes;
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


    function getContent(uint256 _topicId,uint256 _contentId)
        private
        view
        returns (bytes memory,bytes memory, address)
    {
        Content memory content = Contents[_topicId][_contentId];
        return (content.content, content.others,content.user);
    }

    function getUserContentIndex(address _user,uint256 _topicId) private view returns (uint256) {
        return UserContentIds[_user][_topicId];
    }

    function getContentIdByAddress(address _user,uint256 _topicId, uint256 _index)
        private
        view
        returns (uint256)
    {
        return UserContents[_user][_topicId][_index];
    }

    

    function createContent(uint256 _topicId,bytes memory _content,bytes memory _others) private {
        Content memory newContent = Content(_content, _others,msg.sender);

        uint256 contentId=ContentIds[_topicId];

        Contents[_topicId][contentId]=newContent;

        uint256 currentUserContentIndex = UserContentIds[msg.sender][_topicId];

        UserContents[msg.sender][_topicId][currentUserContentIndex] = contentId;

        UserContentIds[msg.sender][_topicId] = currentUserContentIndex + 1;

        ContentIds[_topicId]++;
    }
}
