## Multisig Wallet leveraging ENS on L2

The application is using ENS names with account abstraction to simplify UX and allow for a more secure experience and accessibility. When combined with account abstraction, users can seamlessly utilize ENS names in their interactions, abstracting away the complexities of handling Ethereum addresses directly.

## Problem

Wallet social recovery is a mechanism that allows users to regain access to their wallets by leveraging a network of trusted contacts. In this approach, users designate a group of trusted individuals who can collectively assist in recovering the wallet in case of loss or forgotten credentials. When the user initiates a recovery process, the wallet sends notifications to the trusted contacts, who then provide their approval or assistance. Once a sufficient number of trusted contacts validate the recovery request, the wallet grants the user access to their funds and account, effectively restoring control over their assets. This method enhances security and provides users with an additional layer of protection against the risk of losing access to their wallets.

Currently, users have to add a fixed wallet address (like 0xycc...) of their guardians. Later, during the recovery phase, the guardians (owners of the guardian addresses) have to approve the recovery by signing the recovery request via the originally specified address. However, a problem arises when guardians lose access to the originally specified Ethereum address due to various reasons. For instance, they may decide to migrate their assets from one wallet to another and unintentionally forget to update all references to the old Ethereum address or informing their friends. This can lead to difficulties in the recovery process as the guardians may no longer have control over the specified address, hindering the successful recovery of the user's wallet.

## Solution

Our idea is to use guardians' ENS addresses instead of fixed addresses. By utilizing ENS addresses, users only need to rely on the stability of the ENS system, rather than worrying about the potential consequences of changing or losing access to their old Ethereum accounts. This approach provides flexibility and simplifies the recovery process, as guardians can update their associated ENS addresses if needed, without causing disruptions or hindering the recovery of users' wallets.
