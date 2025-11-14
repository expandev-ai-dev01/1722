/**
 * @summary
 * Global test environment setup.
 * Configures Jest and provides shared test utilities.
 *
 * @module tests/testSetup
 */

import dotenv from 'dotenv';

// Load test environment variables
dotenv.config({ path: '.env.test' });

// Global test setup
beforeAll(() => {
  console.log('Test environment initialized');
});

afterAll(() => {
  console.log('Test environment cleanup');
});
