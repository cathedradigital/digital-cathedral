// Lovable integration module
// Provides OAuth and authentication utilities for Lovable SDK

import { createLovableAuth } from "@lovable.dev/cloud-auth-js";

export const lovable = {
  auth: createLovableAuth({
    // Configuration for OAuth and authentication
    // The SDK will handle Google, Apple, and other providers
  }),
};

export default lovable;
