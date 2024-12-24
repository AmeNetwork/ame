// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "../../Ame/Types.sol";
import "../../Ame/IComponent.sol";

contract Jutsu is IComponent {
    struct Project {
        uint256 id;
        string name;
        address owner;
    }

    uint256 public projectIds;
    mapping(string => Project) ProjectInfo;
    mapping(uint256 => string) ProjectIdName;
    mapping(string => mapping(string => string)) ProjectVerisonCID;
    mapping(string => string[]) ProjectVersion;
    mapping(string => mapping(string => uint256)) ProjectVersionDate;
    mapping(address => uint256) UserProjectId;

    event PublishProject(
        string indexed _name,
        string _version,
        string indexed _cid,
        address indexed _from,
        uint256 _date
    );

    //@dev Types contains all data types in solidity
    mapping(string => Types.Type[]) methodRequests;
    mapping(string => Types.Type[]) methodResponses;
    mapping(MethodTypes => string[]) methods;

    constructor() {
        Types.Type[] memory type1 = new Types.Type[](3);
        type1[0] = Types.Type.STRING;
        type1[1] = Types.Type.STRING;
        type1[2] = Types.Type.STRING;

        Types.Type[] memory type2 = new Types.Type[](2);
        type2[0] = Types.Type.STRING;
        type2[1] = Types.Type.STRING;

        Types.Type[] memory type3 = new Types.Type[](2);
        type3[0] = Types.Type.BOOL;
        type3[1] = Types.Type.STRING;

        Types.Type[] memory type4 = new Types.Type[](1);
        type4[0] = Types.Type.STRING;

        Types.Type[] memory type5 = new Types.Type[](6);
        type5[0] = Types.Type.UINT256;
        type5[1] = Types.Type.STRING;
        type5[2] = Types.Type.ADDRESS;
        type5[3] = Types.Type.STRING;
        type5[4] = Types.Type.STRING;
        type5[5] = Types.Type.UINT256;

        Types.Type[] memory type6 = new Types.Type[](3);
        type6[0] = Types.Type.STRING_ARRAY;
        type6[1] = Types.Type.STRING_ARRAY;
        type6[2] = Types.Type.UINT256_ARRAY;

        Types.Type[] memory type7 = new Types.Type[](2);
        type7[0] = Types.Type.UINT256;
        type7[1] = Types.Type.UINT256;

        Types.Type[] memory type8 = new Types.Type[](6);
        type8[0] = Types.Type.UINT256_ARRAY;
        type8[1] = Types.Type.STRING_ARRAY;
        type8[2] = Types.Type.ADDRESS_ARRAY;
        type8[3] = Types.Type.STRING_ARRAY;
        type8[4] = Types.Type.STRING_ARRAY;
        type8[5] = Types.Type.UINT256_ARRAY;

        Types.Type[] memory type9 = new Types.Type[](3);
        type9[0] = Types.Type.STRING;
        type9[1] = Types.Type.STRING;
        type9[2] = Types.Type.ADDRESS;

        Types.Type[] memory type10 = new Types.Type[](1);
        type10[0] = Types.Type.UINT256;

        setMethod("publishCheck", MethodTypes.GET, type9, type3);

        setMethod(
            "publishProject",
            MethodTypes.POST,
            type1,
            new Types.Type[](0)
        );
        setMethod("getProject", MethodTypes.GET, type4, type5);
        setMethod("getCIDByVersion", MethodTypes.GET, type2, type4);
        setMethod("getVersions", MethodTypes.GET, type4, type6);
        setMethod("getProjects", MethodTypes.GET, type7, type8);
        setMethod("getProjectTotal",MethodTypes.GET,new Types.Type[](0),type10);
    }

    function publishCheck(
        string memory _name,
        string memory _version,
        address _from
    ) internal view returns (bool, string memory) {
        if (ProjectInfo[_name].owner == address(0)) {
            return (true, "Passed");
        } else {
            if (ProjectInfo[_name].owner == _from) {
                if (bytes(ProjectVerisonCID[_name][_version]).length == 0) {
                    return (true, "Passed");
                } else {
                    return (false, "Duplicate Version");
                }
            } else {
                return (false, "Duplicate Name");
            }
        }
    }

    function get(string memory _methodName, bytes memory _methodReq)
        public
        view
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "publishCheck")) {
            (string memory name, string memory version, address from) = abi
                .decode(_methodReq, (string, string, address));
            (bool isValid, string memory result) = publishCheck(
                name,
                version,
                from
            );

            return abi.encode(isValid, result);
        } else if (compareStrings(_methodName, "getProject")) {
            string memory name = abi.decode(_methodReq, (string));
            if (ProjectInfo[name].owner != address(0)) {
                string[] memory ProjectVersions = ProjectVersion[name];
                string memory latestVersion = ProjectVersions[
                    ProjectVersions.length - 1
                ];
                string memory cid = ProjectVerisonCID[name][latestVersion];
                return (
                    abi.encode(
                        ProjectInfo[name].id,
                        ProjectInfo[name].name,
                        ProjectInfo[name].owner,
                        latestVersion,
                        cid,
                        ProjectVersionDate[name][latestVersion]
                    )
                );
            } else {
                return abi.encode(0, "", address(0), "", "");
            }
        } else if (compareStrings(_methodName, "getProjects")) {
            (uint256 pageNum, uint256 pageSize) = abi.decode(
                _methodReq,
                (uint256, uint256)
            );

            (
                uint256[] memory ids,
                string[] memory names,
                address[] memory owners,
                string[] memory versions,
                string[] memory cids,
                uint256[] memory dates
            ) = getProjects(pageNum, pageSize);

            return abi.encode(ids, names, owners, versions, cids, dates);
        } else if (compareStrings(_methodName, "getCIDByVersion")) {
            (string memory name, string memory version) = abi.decode(
                _methodReq,
                (string, string)
            );
            return (abi.encode(ProjectVerisonCID[name][version]));
        } else if (compareStrings(_methodName, "getVersions")) {
            string memory name = abi.decode(_methodReq, (string));
            string[] memory versions = ProjectVersion[name];
            string[] memory cids = new string[](versions.length);
            uint256[] memory dates = new uint256[](versions.length);
            for (uint256 i = 0; i < versions.length; i++) {
                cids[i] = ProjectVerisonCID[name][versions[i]];
                dates[i] = ProjectVersionDate[name][versions[i]];
            }
            return abi.encode(versions, cids, dates);
        } else if (compareStrings(_methodName, "getProjectTotal")) {
            return abi.encode(projectIds);
        } else {
            return abi.encode("");
        }
    }

    function post(string memory _methodName, bytes memory _methodReq)
        public
        payable
        returns (bytes memory)
    {
        if (compareStrings(_methodName, "publishProject")) {
            (string memory name, string memory version, string memory cid) = abi
                .decode(_methodReq, (string, string, string));

            //new project
            if (ProjectInfo[name].owner == address(0)) {
                ProjectInfo[name] = Project(projectIds, name, msg.sender);
                ProjectIdName[projectIds] = name;
                ProjectVerisonCID[name][version] = cid;
                ProjectVersion[name].push(version);
                ProjectVersionDate[name][version] = block.timestamp;
                projectIds++;
            } else {
                //update project
                require(
                    ProjectInfo[name].owner == msg.sender,
                    "You are not the owner of this project"
                );
                require(
                    bytes(ProjectVerisonCID[name][version]).length == 0,
                    "Version name already exists"
                );
                ProjectVerisonCID[name][version] = cid;
                ProjectVersion[name].push(version);
                ProjectVersionDate[name][version] = block.timestamp;
            }

            emit PublishProject(
                name,
                version,
                cid,
                msg.sender,
                block.timestamp
            );

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
        if (compareStrings(_methodName, "updateUserName")) {}
        return abi.encode(_methodReq);
    }

    function getProjects(uint256 _pageNum, uint256 _pageSize)
        public
        view
        returns (
            uint256[] memory,
            string[] memory,
            address[] memory,
            string[] memory,
            string[] memory,
            uint256[] memory
        )
    {
        if (projectIds == 0) {
            return (
                new uint256[](0),
                new string[](0),
                new address[](0),
                new string[](0),
                new string[](0),
                new uint256[](0)
            );
        } else {
            if (
                _pageNum > 1 && ((projectIds - 1) / _pageSize) < (_pageNum - 1)
            ) {
                return (
                    new uint256[](0),
                    new string[](0),
                    new address[](0),
                    new string[](0),
                    new string[](0),
                    new uint256[](0)
                );
            } else {
                uint256 arrayLength;
                uint256 arrayIndex = 0;

                uint256 dataStart = (projectIds - 1) -
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

                uint256[] memory ids = new uint256[](arrayLength);
                string[] memory names = new string[](arrayLength);
                address[] memory owners = new address[](arrayLength);
                string[] memory versions = new string[](arrayLength);
                string[] memory cids = new string[](arrayLength);
                uint256[] memory dates = new uint256[](arrayLength);

                for (int256 i = int256(dataStart); i >= int256(dataEnd); i--) {
                    ids[arrayIndex] = uint256(i);

                    Project memory project = ProjectInfo[
                        ProjectIdName[uint256(i)]
                    ];
                    names[arrayIndex] = project.name;
                    owners[arrayIndex] = project.owner;
                    string[] memory projectVersions = ProjectVersion[
                        project.name
                    ];
                    string memory version = projectVersions[
                        projectVersions.length - 1
                    ];
                    versions[arrayIndex] = version;
                    cids[arrayIndex] = ProjectVerisonCID[project.name][version];
                    dates[arrayIndex] = ProjectVersionDate[project.name][
                        version
                    ];

                    arrayIndex++;
                }
                return (ids, names, owners, versions, cids, dates);
            }
        }
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
}
