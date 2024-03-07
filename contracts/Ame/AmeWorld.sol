// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;
import "./IAmeWorld.sol";
contract AmeWorld is IAmeWorld{

    mapping(address=>bool) registerState;
    mapping(address=>address[]) components;

    function register()public {
        registerState[msg.sender]=true;
    }

    function isRegistered(address _user)public view returns(bool){
        return registerState[_user];
    }

    function addComponents(address[] memory _components)public{
        require(isRegistered(msg.sender));
        for(uint256 i=0;i<_components.length;i++){
            if(hasComponent( msg.sender, _components[i])){
                revert("The component has been added");
            }else{
                components[msg.sender].push(_components[i]);
            }
        }
    }

    function removeComponents(address[] memory _components)public {
        require(isRegistered(msg.sender));
        for(uint256 i=0;i<_components.length;i++){
            if(hasComponent(msg.sender,_components[i])){
                uint256 removeIndex;
                for (uint256 j = 0; j < components[msg.sender].length; j++) {
                    if (components[msg.sender][j] == _components[i]) {
                        removeIndex = j;
                        break;
                    }
                }
                for (
                    uint256 k = removeIndex;
                    k < components[msg.sender].length - 1;
                    k++
                ) {
                    components[msg.sender][k] = components[msg.sender][k + 1];
                }
                components[msg.sender].pop();
            }else{
                revert("You did not add this component");
            }

        }
    }

    function getComponents(address _user)public view returns(address[] memory){
        return components[_user];
    }

    function hasComponent(address _user,address _component)public view returns(bool){
        address[] memory userComponets=components[_user];
        for (uint256 i = 0; i < userComponets.length; i++) {
            if (userComponets[i] == _component) {
                return true;
            }
        }
        return false;
    }


    
}