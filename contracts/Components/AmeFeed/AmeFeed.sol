// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
contract AmeFeed is IComponent{


    struct Content{
        string content;
        address user;
    }

    uint256 contentIds=0;

    mapping (uint256=>Content) Contents;
    mapping (address=>uint256) UserContentIds;
    mapping (address=>mapping (uint256=>uint256)) UserContents;


    mapping (string=>Types.Type[]) methodRequests;
    mapping (string=>Types.Type[]) methodResponses;
    mapping (MethodTypes=>string[]) methods;


    constructor(){
        Types.Type[] memory getContentIdsResArray = new Types.Type[](1);
        getContentIdsResArray[0] = Types.Type.UINT256;

        Types.Type[] memory getContentReqArray = new Types.Type[](1);
        getContentReqArray[0] = Types.Type.UINT256;
        Types.Type[] memory getContentResArray = new Types.Type[](2);
        getContentResArray[0] = Types.Type.STRING;
        getContentResArray[1] = Types.Type.ADDRESS;


        Types.Type[] memory getUserContentIndexReqArray = new Types.Type[](1);
        getUserContentIndexReqArray[0]=Types.Type.ADDRESS;

        Types.Type[] memory getContentIdByAddressReqArray = new Types.Type[](2);
        getContentIdByAddressReqArray[0] = Types.Type.ADDRESS;
        getContentIdByAddressReqArray[1] = Types.Type.UINT256;
            
          
        Types.Type[] memory createContentReqArray = new Types.Type[](1);
        createContentReqArray[0]=Types.Type.STRING;


        setMethod("getContentIds",MethodTypes.GET,new Types.Type[](0),getContentIdsResArray);
        setMethod("getContent",MethodTypes.GET,getContentReqArray,getContentResArray);
        setMethod("getUserContentIndex",MethodTypes.GET,getUserContentIndexReqArray,getContentIdsResArray);
        setMethod("getContentIdByAddress",MethodTypes.GET,getContentIdByAddressReqArray,getContentIdsResArray);
        setMethod("createContent",MethodTypes.POST,createContentReqArray,new Types.Type[](0));

    }

    function setMethod(string memory _methodName,MethodTypes _methodType,Types.Type[] memory _methodReq,Types.Type[] memory _methodRes)  private  {
        methods[_methodType].push(_methodName);
        methodRequests[_methodName]=_methodReq;
        methodResponses[_methodName]=_methodRes;
    }

    function getMethodReqAndRes(string memory _methodName)public view returns(Types.Type[] memory ,Types.Type[] memory ){
        return(
            methodRequests[_methodName],
            methodResponses[_methodName]
        );
    }
    
    function getMethods(MethodTypes _methodTypes)public view returns (string[] memory){
        return methods[_methodTypes];
    } 

    function get(string memory _methodName,bytes memory _methodReq)public view returns(bytes memory){
        if(compareStrings(_methodName,"getContentIds")){
            return abi.encode(getContentIds());
        }else if(compareStrings(_methodName,"getContent")){
            (string memory userContent,address user)=  getContent(abi.decode(_methodReq, (uint256))); 
            return abi.encode(userContent,user);
        }else if(compareStrings(_methodName,"getUserContentIndex")){
            (uint256 userContentIndex)= getUserContentIndex(abi.decode(_methodReq, (address)));  
            return abi.encode(userContentIndex);
        }else if(compareStrings(_methodName,"getContentIdByAddress")){
            (address user,uint256 contentIndex)=abi.decode(_methodReq, (address,uint256));
            (uint256 contentId)=getContentIdByAddress(user,contentIndex);
            return abi.encode(contentId);
        }else{
            return abi.encode("");
        } 
    }

    function post(string memory _methodName,bytes memory _methodReq)public payable returns(bytes memory){
        if(compareStrings(_methodName,"createContent")){
            (string memory content)=abi.decode(_methodReq, (string));
            createContent(content);
        }
        return abi.encode("");
    }

    function put(string memory _methodName,bytes memory _methodReq)public payable returns(bytes memory){
        return abi.encode(_methodName,_methodReq);
    }
    
    function options()public pure returns(MethodTypes[] memory){
        MethodTypes[] memory methodTypes=new MethodTypes[](3);
        methodTypes[0]=MethodTypes.GET;
        methodTypes[1]=MethodTypes.POST;
        methodTypes[2]=MethodTypes.OPTIONS;
        return methodTypes;
    }

    //@dev compares two strings for equality
    function compareStrings(string memory _a, string memory _b) private  pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    function getContentIds()private view returns(uint256){
        return contentIds;
    }

    function getContent(uint256 _contentId)private view returns(string memory,address){
        Content memory content=Contents[_contentId];
        return (content.content,content.user);
    }

    function getUserContentIndex(address _user)private view returns(uint256){
        return UserContentIds[_user];
    }

    function getContentIdByAddress(address _user,uint256 _index)private view returns(uint256){
        return UserContents[_user][_index];
    }

    function createContent(string memory _content)private{
        Content memory newContent=Content(_content,msg.sender);

        Contents[contentIds]=newContent;

        uint256 currentUserContentIndex=UserContentIds[msg.sender];

        UserContents[msg.sender][currentUserContentIndex]=contentIds;

        UserContentIds[msg.sender]=currentUserContentIndex+1;

        contentIds++;
    }



    

}