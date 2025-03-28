// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
contract Component is IComponent{

    //@dev define the data type of this component
    struct Profiles{
        string name;
        uint256 age;
    }

    mapping (address=>Profiles) users;

    //@dev Types contains all data types in solidity
    mapping (string=>Types.Type[]) methodRequests;
    mapping (string=>Types.Type[]) methodResponses;
    mapping (MethodTypes=>string[]) methods;

    constructor(){
        Types.Type[] memory getReqArray = new Types.Type[](1);
        getReqArray[0] = Types.Type.ADDRESS;
        Types.Type[] memory dataTypeArray = new Types.Type[](2);
        dataTypeArray[0] = Types.Type.STRING;
        dataTypeArray[1] = Types.Type.UINT256;
        Types.Type[] memory putReqArray = new Types.Type[](2);
        putReqArray[0] = Types.Type.ADDRESS;
        putReqArray[1] = Types.Type.STRING;
        // @dev initialize get, post, put request parameter data types and response data types
        setMethod("getUser",MethodTypes.GET,getReqArray,dataTypeArray);
        setMethod("createUser",MethodTypes.POST,dataTypeArray,new Types.Type[](0));
        setMethod("updateUserName",MethodTypes.PUT,putReqArray,new Types.Type[](0));
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

    function get(string memory _methodName,bytes memory _methodReq)public pure  returns(bytes memory){
           return abi.encode(_methodName,_methodReq);
    }

    function post(string memory _methodName,bytes memory _methodReq)public payable  returns(bytes memory){
        if(compareStrings(_methodName,"testEvent")){
            (string memory name,uint256 age)=abi.decode(_methodReq, (string,uint256));
            users[msg.sender]=Profiles(name,age);
            
        }
        return abi.encode("");
    }

    function put(string memory _methodName,bytes memory _methodReq)public payable returns(bytes memory){
        return abi.encode(_methodName,_methodReq);
    }
    
    function options()public pure returns(MethodTypes[] memory){
        MethodTypes[] memory methodTypes=new MethodTypes[](2);
        methodTypes[0]=MethodTypes.POST;
        methodTypes[1]=MethodTypes.OPTIONS;
        return methodTypes;
    }

    //@dev compares two strings for equality
    function compareStrings(string memory _a, string memory _b) private  pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    

}