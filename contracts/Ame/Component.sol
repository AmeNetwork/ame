// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "./Types.sol";
import "./IComponent.sol";
contract Component is IComponent{

    mapping (MethodTypes=>string[]) methods;
    mapping (string=>Types.Type[]) methodRequests;
    mapping (string=>Types.Type[]) methodResponses;

    constructor(){

    }

    function get(string memory _methodName,bytes memory _methodReq)public pure returns(bytes memory){
        return abi.encode(_methodName,_methodReq);
    }

    function post(string memory _methodName,bytes memory _methodReq)public pure returns(bytes memory){
         return abi.encode(_methodName,_methodReq);
    }

    function put(string memory _methodName,bytes memory _methodReq)public pure returns(bytes memory){
         return abi.encode(_methodName,_methodReq);
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