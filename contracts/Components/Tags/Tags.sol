// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
contract TagsComponent is IComponent{

    
    mapping (string=>Types.Type[]) methodRequests;
    mapping (string=>Types.Type[]) methodResponses;
    mapping (MethodTypes=>string[]) methods;

    struct Tag{
        string tagCategory;
        string[] tags;
    }
    uint256 tagId=0;
    mapping(uint256=>Tag) Tags;
    mapping(address=>mapping (uint256=>string[])) UserTags;

    address public  owner;

    constructor(){

        owner=msg.sender;

        Types.Type[] memory type1 = new Types.Type[](2);
        type1[0]=Types.Type.STRING;
        type1[1]=Types.Type.STRING_ARRAY;

        Types.Type[] memory type2 = new Types.Type[](3);
        type2[0]=Types.Type.UINT256;
        type2[1]=Types.Type.STRING;
        type2[2]=Types.Type.STRING_ARRAY;

        Types.Type[] memory type3 = new Types.Type[](1);
        type3[0]=Types.Type.UINT256;

        Types.Type[] memory type4 = new Types.Type[](1);
        type4[0]=Types.Type.STRING_ARRAY;

        Types.Type[] memory type5 = new Types.Type[](2);
        type5[0]=Types.Type.ADDRESS;
        type5[1]=Types.Type.UINT256;

        Types.Type[] memory type6 = new Types.Type[](2);
        type6[0]=Types.Type.UINT256;
        type6[1]=Types.Type.STRING_ARRAY;

        setMethod("ownerCreateTag",MethodTypes.POST,type1,new Types.Type[](0));
        setMethod("ownerSetTag",MethodTypes.PUT,type2,new Types.Type[](0));
        setMethod("getTagCount",MethodTypes.GET,new Types.Type[](0),type3);
        setMethod("getTagsById",MethodTypes.GET,type3,type4);
        setMethod("setUserTags",MethodTypes.PUT,type6,new Types.Type[](0));
        setMethod("getUserTags",MethodTypes.GET,type5,type4);


    }


    function post(string memory _methodName,bytes memory _methodReq)public   returns(bytes memory){
        if(compareStrings(_methodName,"ownerCreateTag")){
            (string memory tagCategory,string[] memory tags)=abi.decode(_methodReq, (string,string[]));
            Tags[tagId]=Tag(tagCategory,tags);
            tagId++;
            return  abi.encode("");
        }
        return abi.encode("");
    }


    function put(string memory _methodName,bytes memory _methodReq)public  returns(bytes memory){
        if(compareStrings(_methodName,"ownerSetTag")){
            (uint256 updateId,string memory tagCategory,string[] memory tags)=abi.decode(_methodReq, (uint256,string,string[]));
            Tags[updateId]=Tag(tagCategory,tags);
        }else if(compareStrings(_methodName,"setUserTags")){ 
            (uint256 userTagId,string[] memory tags)=abi.decode(_methodReq, (uint256,string[]));
            UserTags[msg.sender][userTagId]=tags;
        }
        return abi.encode("");
    }

    function get(string memory _methodName,bytes memory _methodReq)public view returns(bytes memory){
        if(compareStrings(_methodName,"getTagCount")){
            bytes memory tagIdEncode=abi.encode(tagId);
            return tagIdEncode;
        }else if(compareStrings(_methodName,"getTagsById")){
            uint256 queryId=abi.decode(_methodReq, (uint256));
            string[] memory tags=Tags[queryId].tags;
            bytes memory encodeTags=abi.encode(tags);
            return encodeTags;
        }else if(compareStrings(_methodName,"getUserTags")){
             (address userAddress,uint256 userTagId)=abi.decode(_methodReq, (address,uint256));
             string[] memory userTags=UserTags[userAddress][userTagId];
             bytes memory encodeUserTags=abi.encode(userTags);
             return encodeUserTags;
        }else{
            return abi.encode("");
        }  
    }



    
    function options()public pure returns(MethodTypes[] memory){
        MethodTypes[] memory methodTypes=new MethodTypes[](4);
        methodTypes[0]=MethodTypes.GET;
        methodTypes[1]=MethodTypes.POST;
        methodTypes[2]=MethodTypes.PUT;
        methodTypes[3]=MethodTypes.OPTIONS;
        return methodTypes;
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

    function compareStrings(string memory _a, string memory _b) private  pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    

}