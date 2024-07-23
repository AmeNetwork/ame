// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "./Types.sol";
interface IComponent{

    /**
     * Requested method type.
     * GET, POST, PUT, OPTIONS
     */
    enum MethodTypes{
        GET,
        POST,
        PUT,
        OPTIONS
    }

    /**
     * Response data event.
     * @param _response is the response value of the post request or put request.
     */
    event Response(bytes _response);

    /**
     * Get method names based on request method type.
     * @param _methodTypes is the request method type.
     * @return Method names.
     */
    function getMethods(MethodTypes _methodTypes)external view returns (string[] memory);

    /**
     * Get the data types of request parameters and return parameters based on the requested method name.
     * @param _methodName is the method name.
     * @return Data types of request parameters and return parameters.
     */
    function getMethodReqAndRes(string memory _methodName) external view returns(Types.Type[] memory ,Types.Type[] memory );

    /**
     * Request the contract to retrieve records.
     * @param _methodName is the method name.
     * @param _methodReq is the method type.
     * @return The response to the get request.
     */
    function get(string memory _methodName,bytes memory _methodReq)external view returns(bytes memory);

    /**
     * Request the contract to create a new record.
     * @param _methodName is the method name.
     * @param _methodReq is the method type.
     * @return The response to the post request.
     */
    function post(string memory _methodName,bytes memory _methodReq)external payable returns(bytes memory);

    /**
     * Request the contract to update a record.
     * @param _methodName is the method name.
     * @param _methodReq is the method type.
     * @return The response to the put request.
     */
    function put(string memory _methodName,bytes memory _methodReq)external payable returns(bytes memory);

    /**
     * Supported request method types.
     * @return Method types.
     */
    function options()external returns(MethodTypes[] memory);
}