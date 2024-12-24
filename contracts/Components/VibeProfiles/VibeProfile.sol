// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
import "../../Ame/lib/Strings.sol";
import "../../Ame/lib/Base64.sol";

contract VibeProfile is IComponent {
    using Strings for uint256;

    mapping(MethodTypes => string[]) methods;

    //@dev Types contains all data types in solidity
    mapping(string => Types.Type[]) methodRequests;
    mapping(string => Types.Type[]) methodResponses;

    struct UserInfo{
       string handle;
       string nickname;
       string avatar;
       string profile;
    }

    mapping (address => UserInfo) addressUserInfo;
    mapping (string=>address) handleAddresses;

    event UpdateProfile(address indexed  _user,string indexed _handle,string _nickname,string _avatar,string _profile);

    constructor() {
        Types.Type[] memory type1 = new Types.Type[](4);
        type1[0] = Types.Type.STRING;
        type1[1] = Types.Type.STRING;
        type1[2] = Types.Type.STRING;
        type1[3] = Types.Type.STRING;


        Types.Type[] memory type2 = new Types.Type[](3);
        type2[0] = Types.Type.STRING;
        type2[1] = Types.Type.STRING;
        type2[2] = Types.Type.STRING;


        Types.Type[] memory type3 = new Types.Type[](1);
        type3[0] = Types.Type.ADDRESS_ARRAY;

        Types.Type[] memory type4 = new Types.Type[](4);
        type4[0] = Types.Type.STRING_ARRAY;
        type4[1] = Types.Type.STRING_ARRAY;
        type4[2] = Types.Type.STRING_ARRAY;
        type4[3] = Types.Type.STRING_ARRAY;

        Types.Type[] memory type5 = new Types.Type[](1);
        type5[0] = Types.Type.ADDRESS;

        Types.Type[] memory type6 = new Types.Type[](1);
        type6[0] = Types.Type.STRING;

        Types.Type[] memory type7 = new Types.Type[](1);
        type7[0] = Types.Type.STRING_ARRAY;

        Types.Type[] memory type8 = new Types.Type[](4);
        type8[0] = Types.Type.ADDRESS_ARRAY;
        type8[1] = Types.Type.STRING_ARRAY;
        type8[2] = Types.Type.STRING_ARRAY;
        type8[3] = Types.Type.STRING_ARRAY;

        setMethod("createUser", MethodTypes.POST, type1, new Types.Type[](0));
        setMethod("updateUserInfo", MethodTypes.PUT, type2, new Types.Type[](0));
        setMethod("getUserInfoByAddresses", MethodTypes.GET, type3, type4);
        setMethod("getUserInfoByHandles", MethodTypes.GET, type7, type8);
        setMethod("getAddressByHandle", MethodTypes.GET, type6, type5);

       
    }

    function get(string memory _methodName, bytes memory _methodReq)
        public
        view
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "getUserInfoByAddresses")) {

            (address[] memory users) = abi.decode(_methodReq, (address[]));
            
            string[] memory handles=new string[](users.length);
            string[] memory nincknames=new string[](users.length);
            string[] memory avatars=new string[](users.length);
            string[] memory profiles=new string[](users.length);

            for(uint256 i=0;i<users.length;i++){
                UserInfo memory userInfo=addressUserInfo[users[i]];
                handles[i]=userInfo.handle;
                nincknames[i]=userInfo.nickname;
                avatars[i]=userInfo.avatar;
                profiles[i]=userInfo.profile;
            }

            return abi.encode(handles,nincknames,avatars,profiles);
            
        }else if (compareStrings(_methodName, "getUserInfoByHandles")) {

            (string[] memory _handles) = abi.decode(_methodReq, (string[]));
            
            address[] memory users=new address[](_handles.length);
            string[] memory nincknames=new string[](_handles.length);
            string[] memory avatars=new string[](_handles.length);
            string[] memory profiles=new string[](_handles.length);

            for(uint256 i=0;i<_handles.length;i++){
                UserInfo memory userInfo=addressUserInfo[handleAddresses[_handles[i]]];
                users[i]=handleAddresses[_handles[i]];
                nincknames[i]=userInfo.nickname;
                avatars[i]=userInfo.avatar;
                profiles[i]=userInfo.profile;
            }

            return abi.encode(users,nincknames,avatars,profiles);
            
        }else if(compareStrings(_methodName, "getAddressByHandle")){

            (string memory _handle) = abi.decode(_methodReq, (string));
            return abi.encode(handleAddresses[_handle]);

        } else {
            return abi.encode("");
        }
    }

    function post(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {

        
        if (compareStrings(_methodName, "createUser")) {

            (string memory _handle, string memory _nickname, string memory _avatar,string memory _profile) = abi.decode(_methodReq, (string,string,string,string));

            require(isValidString(_handle),"handle is invalid");
            
            UserInfo memory userInfo=addressUserInfo[msg.sender];

            require(handleAddresses[_handle]==address(0),"the handle has been registered");
            
       

            if(isEmptyString(userInfo.handle)){
                addressUserInfo[msg.sender]=UserInfo(_handle,_nickname,_avatar,_profile);
                handleAddresses[_handle]=msg.sender;
                
                emit UpdateProfile( msg.sender, _handle, _nickname, _avatar, _profile);
            }else{
                revert("user has registered");
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
        if(compareStrings(_methodName, "updateUserInfo")){

            UserInfo memory userInfo=addressUserInfo[msg.sender];
            if(!isEmptyString(userInfo.handle)){
            ( string memory _nickname, string memory _avatar,string memory _profile) = abi.decode(_methodReq, (string,string,string));
      
            userInfo.nickname=_nickname;
            userInfo.avatar=_avatar;
            userInfo.profile=_profile;
            addressUserInfo[msg.sender]=userInfo;

            emit UpdateProfile( msg.sender, userInfo.handle, _nickname, _avatar, _profile);
            }else{
                revert("the user is not registered");
            }
        }
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

    function isEmptyString(string memory str) public pure returns (bool) {

        bytes memory strBytes = bytes(str);
   
        return strBytes.length == 0;
    }

    function toLower(string memory str) public pure returns (string memory) {
        bytes memory bStr = bytes(str);
        bytes memory bLower = new bytes(bStr.length);

        for (uint i = 0; i < bStr.length; i++) {
            
            if (bStr[i] >= 0x41 && bStr[i] <= 0x5A) { 
                bLower[i] = bytes1(uint8(bStr[i]) + 32); 
            } else {
                bLower[i] = bStr[i]; 
            }
        }
        return string(bLower);
    }



     function isValidString(string memory str) public pure returns (bool) {
        bytes memory strBytes = bytes(str);
        

        if (strBytes.length == 0 || strBytes.length > 20) return false;

        for (uint i = 0; i < strBytes.length; i++) {
            bytes1 char = strBytes[i];
            
  
            if (char >= 0x61 && char <= 0x7A) {
                continue;
            }
      
            else if (char >= 0x30 && char <= 0x39) {
                continue;
            }

            else if (char == 0x5F) {
                continue;
            }

            else {
                return false;
            }
        }
        
        return true;
    }





 


}
