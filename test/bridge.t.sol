import {Bridge} from "src/bridge_contract.sol";
import {FederationSync} from "src/federation_contract.sol";

contract BridgeTest is Test {
    Bridge public bridge;
    FederationSync public federationSync;

    function setUp() public {
        bridge = new Bridge();
        federationSync = new FederationSync();
    }
}
