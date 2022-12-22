// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "./HashList.sol";

contract HashListExample2 {
    using HashList2 for HashListData2;
    HashListData2 hld;
    function add(uint item) public {
        hld.add(item);
    }
}
contract HashListExample3 {
    using HashList3 for HashListData3;
    HashListData3 hld;
    function add(uint item) public {
        hld.add(item);
    }
}
contract HashListExample4 {
    using HashList4 for HashListData4;
    HashListData4 hld;
    function add(uint item) public {
        hld.add(item);
    }
}
contract HashListExample5 {
    using HashList5 for HashListData5;
    HashListData5 hld;
    function add(uint item) public {
        hld.add(item);
    }
}
contract HashListExample6 {
    using HashList6 for HashListData6;
    HashListData6 hld;
    function add(uint item) public {
        hld.add(item);
    }
}
