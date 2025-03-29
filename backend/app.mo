import Array "mo:base/Array";
import Debug "mo:base/Debug";
import Principal "mo:base/Principal";
import Nat "mo:base/Nat";

actor StartShield {
  // Type definitions
  type Role = {
    id: Nat;
    name: Text;
  };

  type User = {
    id: Principal;
    name: Text;
    role: Role;
  };

  type Policy = {
    id: Nat;
    holder: Principal;
    premium: Nat;
    coverage: Text;
    status: Text;
  };

  type Claim = {
    id: Nat;
    policyId: Nat;
    amount: Nat;
    description: Text;
    status: Text;
  };

  // State variables
  private stable var nextPolicyId: Nat = 1;
  private stable var nextClaimId: Nat = 1;
  
  private var users: [User] = [];
  private var policies: [Policy] = [];
  private var claims: [Claim] = [];

  // Predefined roles
  private let ADMIN_ROLE: Role = { id = 1; name = "Admin" };
  private let FARMER_ROLE: Role = { id = 2; name = "Farmer" };

  // User management
  public func registerUser(name: Text, roleId: Nat) : async User {
    let caller = Principal.fromActor(StartShield);
    
    // Determine role
    let role = if (roleId == 1) ADMIN_ROLE else FARMER_ROLE;
    
    let newUser = {
      id = caller;
      name = name;
      role = role;
    };
    
    users := Array.append(users, [newUser]);
    Debug.print("Registered user: " # name);
    
    return newUser;
  };

  // Policy management
  public func createPolicy(holderName: Text, premium: Nat, coverage: Text) : async Policy {
    let holder = Principal.fromActor(StartShield);
    
    let newPolicy = {
      id = nextPolicyId;
      holder = holder;
      premium = premium;
      coverage = coverage;
      status = "Active";
    };
    
    policies := Array.append(policies, [newPolicy]);
    nextPolicyId += 1;
    
    Debug.print("Created policy for: " # holderName);
    return newPolicy;
  };

  public query func getPolicies() : async [Policy] {
    return policies;
  };

  // Claims management
  public func fileClaim(policyId: Nat, amount: Nat, description: Text) : async Claim {
    let newClaim = {
      id = nextClaimId;
      policyId = policyId;
      amount = amount;
      description = description;
      status = "Pending";
    };
    
    claims := Array.append(claims, [newClaim]);
    nextClaimId += 1;
    
    Debug.print("Filed claim for policy: " # Nat.toText(policyId));
    return newClaim;
  };

  public query func getClaims() : async [Claim] {
    return claims;
  };
};