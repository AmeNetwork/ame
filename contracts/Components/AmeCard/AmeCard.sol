// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v4.2/contracts/access/Ownable.sol";
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";
import "./Strings.sol";
import "./Base64.sol";
contract Component is IComponent,Ownable{

    using Strings for uint256;

    mapping (MethodTypes=>string[]) methods;

    mapping (string=>Types.Type[]) methodRequests;
    mapping (string=>Types.Type[]) methodResponses;

    uint256 public memberIds;
    mapping (uint256 => address) public MemberList;

    mapping (address => bool) public MemberStates;
    mapping (address => uint256) public Points;
    mapping (address => bool) public PointOperatorWhiteLists;
    mapping (address => bool) public MemberOperatorWhiteLists;
    mapping (address => string) public Customiztions;
    mapping (address => uint256) public PointsRecordKey;
    mapping (address => mapping(uint256=>string)) public PointRecords;



    constructor()Ownable(){
        Types.Type[] memory type1 = new Types.Type[](2);
        type1[0] = Types.Type.ADDRESS;
        type1[1] = Types.Type.BOOL;

        Types.Type[] memory type2 = new Types.Type[](1);
        type2[0] = Types.Type.ADDRESS;

        Types.Type[] memory type3 = new Types.Type[](1);
        type3[0] = Types.Type.BOOL;

        Types.Type[] memory type4 = new Types.Type[](1);
        type4[0] = Types.Type.UINT256;

        Types.Type[] memory type5 = new Types.Type[](4);
        type5[0] = Types.Type.ADDRESS; //user
        type5[1] = Types.Type.UINT256; //type
        type5[2] = Types.Type.UINT256; //value
        type5[3] = Types.Type.STRING;  //description

        Types.Type[] memory type6 = new Types.Type[](1);
        type6[0] = Types.Type.STRING;

        Types.Type[] memory type7 = new Types.Type[](2);
        type7[0] = Types.Type.ADDRESS;
        type7[1] = Types.Type.STRING;

        Types.Type[] memory type8 = new Types.Type[](2);
        type8[0] = Types.Type.UINT256;
        type8[1] = Types.Type.UINT256;

        Types.Type[] memory type9 = new Types.Type[](2);
        type9[0] = Types.Type.ADDRESS_ARRAY;
        type9[1] = Types.Type.UINT256_ARRAY;

        Types.Type[] memory type10 = new Types.Type[](3);
        type10[0] = Types.Type.ADDRESS;
        type10[1] = Types.Type.UINT256;
        type10[2] = Types.Type.UINT256;

        Types.Type[] memory type11 = new Types.Type[](1);
        type11[0] = Types.Type.ADDRESS_ARRAY;

        Types.Type[] memory type12 = new Types.Type[](1);
        type12[0] = Types.Type.STRING_ARRAY;


        setMethod("setMemberState", MethodTypes.PUT, type1, new Types.Type[](0));
        setMethod("getMemberState", MethodTypes.GET, type2, type3);


        setMethod("getMemberPoints", MethodTypes.GET, type2, type4);
        setMethod("setPointOperatorState", MethodTypes.PUT, type1, new Types.Type[](0));

        setMethod("getMemberOperatorState", MethodTypes.GET, type2, type3);
        setMethod("setMemeberOperatorState", MethodTypes.PUT, type1, new Types.Type[](0));


        setMethod("getPointOperatorState", MethodTypes.GET, type2, type3);
        setMethod("updateCustomiztion", MethodTypes.PUT, type7, new Types.Type[](0));
        setMethod("getCustomiztion", MethodTypes.GET, type2, type6);
        setMethod("handlePoint", MethodTypes.POST, type5, new Types.Type[](0));
        setMethod("getPointRecords", MethodTypes.GET, type10, type12);
        setMethod("getMembers", MethodTypes.GET, type8, type9);
        setMethod("getMembersCount", MethodTypes.GET,new Types.Type[](0), type4);
        setMethod("addMemebers", MethodTypes.POST,type11,new Types.Type[](0));

    }

    function get(string memory _methodName,bytes memory _methodReq)public view returns(bytes memory){

        if (compareStrings(_methodName, "getMemberState")) {

            (
                address _user
         
            ) = abi.decode(
                    _methodReq,
                    (address)
                );
            return abi.encode(MemberStates[_user]);

        }else if(compareStrings(_methodName, "getMemberPoints")){

                    (
                address _user
         
            ) = abi.decode(
                    _methodReq,
                    (address)
                );
            return abi.encode(Points[_user]);

        }else if(compareStrings(_methodName, "getPointOperatorState")){

                    (
                address _operator
         
            ) = abi.decode(
                    _methodReq,
                    (address)
                );
            return abi.encode(PointOperatorWhiteLists[_operator]);

        }else if(compareStrings(_methodName, "getCustomiztion")){

                           (
                address _user
         
            ) = abi.decode(
                    _methodReq,
                    (address)
                );
            return abi.encode(Customiztions[_user]);

        }else if(compareStrings(_methodName, "getPointRecords")){

                  (address _user,
                uint256 _pageNum,
                uint256 _pageSize
         
            ) = abi.decode(
                    _methodReq,
                    (address,uint256,uint256)
                );

             string[] memory records= getPointRecordByAddress(
         _user,
         _pageNum,
         _pageSize);

          return  abi.encode(records);

        }else if(compareStrings(_methodName, "getMembers")){


            (
            uint256 _pageNum,
            uint256 _pageSize
         
            ) = abi.decode(
                _methodReq,
                (uint256,uint256)
            );


        (address[] memory addressArray ,uint256[] memory scoreArray)=getMembers(_pageNum, _pageSize);

        return abi.encode(addressArray,scoreArray);

        }else if(compareStrings(_methodName, "getMembersCount")){

            return abi.encode(memberIds);

        }else if(compareStrings(_methodName, "getMemberOperatorState")){
                    (
                address _operator
         
            ) = abi.decode(
                    _methodReq,
                    (address)
                );
            return abi.encode(MemberOperatorWhiteLists[_operator]);
        }else{
            return abi.encode("");
        }

   
    }





    function post(string memory _methodName,bytes memory _methodReq)public payable  returns(bytes memory){
        if (compareStrings(_methodName, "handlePoint")) {
            address _operator=msg.sender;
            (
                address _user,
                uint256 _type,
                uint256 _value,
                string memory _description
            ) = abi.decode(
                    _methodReq,
                    (address,uint256,uint256,string)
            );
            require(PointOperatorWhiteLists[_operator]);

            if(_type==1){

                Points[_user]=Points[_user]+_value;

            }else{

                if(Points[_user]>=_value){
                    Points[_user]=Points[_user]-_value;
                }else{
                    revert(
                         "not enough points"
                    );
                }
            }

            uint256 userPointRecordKey=PointsRecordKey[_user];
            PointRecords[_user][userPointRecordKey]=generateBase64(_operator,_type,_value,_description,block.timestamp);
            PointsRecordKey[_user]++;
            return abi.encode("");
            
        }else if(compareStrings(_methodName, "addMemebers")){
            require(msg.sender == owner()||MemberOperatorWhiteLists[msg.sender]);
            (
                address[] memory users
            ) = abi.decode(
                    _methodReq,
                    (address[])
            );
            for(uint256 i=0;i<users.length;i++){
                MemberList[memberIds]=users[i];
                MemberStates[users[i]]=true;
                memberIds++;
            }
            return abi.encode("");

        }else{
            return abi.encode("");
        }
    
    }

    function put(string memory _methodName,bytes memory _methodReq)public payable returns(bytes memory){

        if (compareStrings(_methodName, "setMemberState")) {
            require(msg.sender == owner());
            (
                address _user,
                bool _state
         
            ) = abi.decode(
                    _methodReq,
                    (address,bool)
                );

            MemberStates[_user]=_state;
            return abi.encode("");
        }else if(compareStrings(_methodName, "setPointOperatorState")){
            require(msg.sender == owner());
            (
                address _operator,
                bool _state
         
            ) = abi.decode(
                    _methodReq,
                    (address,bool)
                );

            PointOperatorWhiteLists[_operator]=_state;
            return abi.encode("");
        }else if(compareStrings(_methodName, "setMemberOperatorState")){
            require(msg.sender == owner());
            (
                address _operator,
                bool _state
         
            ) = abi.decode(
                    _methodReq,
                    (address,bool)
                );

            MemberOperatorWhiteLists[_operator]=_state;
            return abi.encode("");

        }else if(compareStrings(_methodName, "updateCustomiztion")){
                        (
                address _user,
                string memory _customiztion
         
            ) = abi.decode(
                    _methodReq,
                    (address,string)
                );
            require(msg.sender==_user);
            Customiztions[msg.sender]=_customiztion;
            return abi.encode("");

        } else {
            return abi.encode("");
        }
    }


    function generateBase64(
        address _pointFrom,
        uint256 _pointType,
        uint256 _pointValue,
        string memory _pointDescription,
        uint256 _pointDate
    ) public pure returns(string memory){

        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"from": "',
                       Strings.toHexString(uint256(uint160(_pointFrom)), 20),
                        '", "type":"',
                        _pointType.toString(),
                        '","value":"',
                        _pointValue.toString(),
                        '","description":"',
                        _pointDescription,
                        '","date":"',
                        _pointDate.toString(),  
                        '"}'
                    )
                )
            )
        );
        string memory uri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        return uri; 

    }




    function getMembers(
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (address[] memory,uint256[] memory) {

        if (memberIds == 0) {
            address[] memory tempArray1 = new address[](0);
            uint256[] memory tempArray2 = new uint256[](0);
            return (tempArray1,tempArray2);
        } else {
            if (
                _pageNum > 1 &&
                ((memberIds - 1) / _pageSize) <
                (_pageNum - 1)
            ) {
                address[] memory tempArray1 = new address[](0);
                uint256[] memory tempArray2 = new uint256[](0);
                 return (tempArray1,tempArray2);
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (memberIds - 1) -
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

                address[] memory returnArray1 = new address[](arrayLength);
                uint256[] memory returnArray2 = new uint256[](arrayLength);
                for (int256 i = int256(dataStart); i >= int256(dataEnd); i--) {
                    address member=MemberList[uint256(i)];
                    returnArray1[arrayIndex] = member;
                    returnArray2[arrayIndex]=Points[member];
                    arrayIndex++;
                }
                return (returnArray1,returnArray2);
            }
        }
    }


    function getPointRecordByAddress(
        address _user,
        uint256 _pageNum,
        uint256 _pageSize
    ) public view returns (string[] memory) {
        uint256 userRecordIndex = PointsRecordKey[_user];

        if (userRecordIndex == 0) {
            string[] memory tempArray = new string[](0);
            return tempArray;
        } else {
            if (
                _pageNum > 1 &&
                ((userRecordIndex - 1) / _pageSize) < (_pageNum - 1)
            ) {
                string[] memory tempArray = new string[](0);
                return tempArray;
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (userRecordIndex - 1) -
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
        
                    returnArray[arrayIndex] = PointRecords[_user][uint256(i)];
                    arrayIndex++;
                }
                return returnArray;
            }
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

    //@dev compares two strings for equality
    function compareStrings(string memory _a, string memory _b) private  pure returns (bool) {
        return keccak256(abi.encodePacked(_a)) == keccak256(abi.encodePacked(_b));
    }

    

}