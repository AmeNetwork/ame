// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
interface IAmeWorld{
    /**
     * Register a new user.
     */
    function register()external; 
    
    /**
     * Check if user is registered.
     * @param _user is the user’s address.
     * @return true is registered, false is not registered.
     */
    function isRegistered(address _user)external view returns(bool);

    /**
     * User adds some components.
     * @param _components is contract address of the component.
     */
    function addComponents(address[] memory _components)external;

     /**
     * User removes some components.
     * @param _components is contract address of the component.
     */
    function removeComponents(address[] memory _components)external; 

    /**
     * Get the components that the user has added.
     * @param _user is the user’s address.
     * @return The component address that the user has added.
     */
    function getComponents(address _user)external view returns(address[] memory);

    /**
     * Whether the user added the component.
     * @param _user is the user’s address.
     * @param _component is contract address of the component.
     * @return true is added, false is not added
     */
    function hasComponent(address _user,address _component)external view returns(bool);

}