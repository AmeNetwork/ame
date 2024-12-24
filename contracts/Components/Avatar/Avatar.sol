// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
contract AvatarComponent is IComponent{


    mapping (string=>Types.Type[]) methodRequests;
    mapping (string=>Types.Type[]) methodResponses;
    mapping (MethodTypes=>string[]) methods;

    mapping (address=>uint256) Defaults;
    mapping (address=>string[]) Avatars;

    constructor(){

        Types.Type[] memory type1 = new Types.Type[](1);
        type1[0]=Types.Type.STRING;

        Types.Type[] memory type2 = new Types.Type[](1);
        type2[0]=Types.Type.UINT256;

        Types.Type[] memory type3 = new Types.Type[](1);
        type3[0]=Types.Type.STRING_ARRAY;

        Types.Type[] memory type4 = new Types.Type[](1);
        type4[0]=Types.Type.ADDRESS;


        setMethod("addAvatar",MethodTypes.POST,type1,new Types.Type[](0));
        setMethod("setDefaultAvatar",MethodTypes.PUT,type2,new Types.Type[](0));
        setMethod("getDefaultAvatar",MethodTypes.GET,type4,type1);
        setMethod("getAllAvatars",MethodTypes.GET,type4,type3);
    }



    function get(string memory _methodName,bytes memory _methodReq)public view returns(bytes memory){
        if(compareStrings(_methodName,"getDefaultAvatar")){
            address reqAddress=abi.decode(_methodReq, (address));
            uint256 defaultIndex=Defaults[reqAddress];
            string[] memory avatars=Avatars[reqAddress];
            bytes memory defaultAvatarEncode=abi.encode(avatars[defaultIndex]);
            return defaultAvatarEncode;
        }else if(compareStrings(_methodName,"getAllAvatars")){
            address reqAddress=abi.decode(_methodReq, (address));
            string[] memory avatars=Avatars[reqAddress];
            bytes memory encodeAvatars=abi.encode(avatars);
             return encodeAvatars;
        }else{
            return abi.encode("");
        }  
    }

    function post(string memory _methodName,bytes memory _methodReq)public payable returns(bytes memory){
        if(compareStrings(_methodName,"addAvatar")){
            (string memory avatar)=abi.decode(_methodReq, (string));
            Avatars[msg.sender].push(avatar);
            return  abi.encode("");
        }
        return abi.encode("");
    }

    function put(string memory _methodName,bytes memory _methodReq)public payable returns(bytes memory){
        if(compareStrings(_methodName,"setDefaultAvatar")){
            (uint defaultIndex)=abi.decode(_methodReq, (uint256));
            Defaults[msg.sender]=defaultIndex;
        }
        return abi.encode("");
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