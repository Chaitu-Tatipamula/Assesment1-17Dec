// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

/// @title Ethereum Smart Wallet with Social Media, Biometrics, and Passcode Access
contract SmartWallet is Ownable(msg.sender) {
    using ECDSA for bytes32;

    // Events
    event FundsDeposited(address indexed user, uint256 amount);
    event FundsWithdrawn(address indexed user, uint256 amount);
    event OTPVerified(address indexed user);
    event BiometricVerified(address indexed user);
    event PasscodeSet(address indexed user, bytes32 passcodeHash);

    // Mappings
    mapping(address => bytes32) private passcodeHashes;
    mapping(address => bool) private otpVerified;
    mapping(address => bool) private biometricVerified;

    /// @notice Deposit funds into the wallet
    function deposit() external payable {
        require(msg.value > 0, "Deposit amount must be greater than zero");
        emit FundsDeposited(msg.sender, msg.value);
    }

    /// @notice Withdraw funds from the wallet
    /// @param amount The amount to withdraw
    /// @param passcode The user's passcode
    function withdraw(uint256 amount, string memory passcode) external {
        require(address(this).balance >= amount, "Insufficient funds");
        require(passcodeHashes[msg.sender] != "", "You haven't set any passcode");
        require(_verifyPasscode(msg.sender, passcode), "Invalid passcode");
        require(otpVerified[msg.sender], "OTP not verified");
        require(biometricVerified[msg.sender], "Biometric not verified");

        otpVerified[msg.sender] = false;
        biometricVerified[msg.sender] = false;

        payable(msg.sender).transfer(amount);   
        emit FundsWithdrawn(msg.sender, amount);
    }

    /// @notice Set or update passcode
    /// @param passcode The user's raw passcode
    function setPasscode(string memory passcode) external {
        bytes32 passcodeHash = keccak256(abi.encodePacked(passcode));
        passcodeHashes[msg.sender] = passcodeHash;
        emit PasscodeSet(msg.sender, passcodeHash);
    }

    /// @notice Verify OTP (via off-chain service)
    function verifyOTP() external {
        otpVerified[msg.sender] = true;
        emit OTPVerified(msg.sender);
    }

    /// @notice Verify Biometric Authentication (via off-chain service)
    function verifyBiometric() external {
        biometricVerified[msg.sender] = true;
        emit BiometricVerified(msg.sender);
    }

    /// @dev Verify the passcode
    /// @param user The user address
    /// @param passcode The raw passcode
    /// @return isValid True if the passcode matches
    function _verifyPasscode(address user, string memory passcode) private view returns (bool) {
        bytes32 hashedPasscode = keccak256(abi.encodePacked(passcode));
        return hashedPasscode == passcodeHashes[user];
    }

    /// @notice Fallback to receive Ether
    receive() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }
}
