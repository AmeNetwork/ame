// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
contract KeypairComponent is IComponent{

    mapping (string=>Types.Type[]) methodRequests;
    mapping (string=>Types.Type[]) methodResponses;
    mapping (MethodTypes=>string[]) methods;

    struct Keypair{
        bytes publicKey;
        bytes encryptPrivateKey;
    }

    mapping (address=>Keypair) Keypairs;

    constructor(){

        Types.Type[] memory type1 = new Types.Type[](1);
        type1[0]=Types.Type.ADDRESS;

        Types.Type[] memory type2 = new Types.Type[](2);
        type2[0]=Types.Type.BYTES;
        type2[1]=Types.Type.BYTES;

        setMethod("getKeypair",MethodTypes.GET,type1,type2);
        setMethod("setKeypair",MethodTypes.POST,type2,new Types.Type[](0));
 
    }



    function get(string memory _methodName,bytes memory _methodReq)public view returns(bytes memory){
        if(compareStrings(_methodName,"getKeypair")){
            address reqAddress=abi.decode(_methodReq, (address));
            Keypair memory userKeypair =Keypairs[reqAddress];
            bytes memory defaultAvatarEncode=abi.encode(userKeypair.publicKey,userKeypair.encryptPrivateKey);
            return defaultAvatarEncode;
        }else{
            return abi.encode("");
        }  
    }

    function post(string memory _methodName,bytes memory _methodReq)public payable returns(bytes memory){
        if(compareStrings(_methodName,"setKeypair")){
            (bytes memory publicKey,bytes memory encryptPrivateKey)=abi.decode(_methodReq, (bytes,bytes));
            Keypairs[msg.sender]=Keypair(publicKey,encryptPrivateKey);
            return  abi.encode("");
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