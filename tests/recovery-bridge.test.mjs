import test from 'node:test';
import assert from 'node:assert/strict';
import { recoveryAppUrl } from '../src/utils/recoveryBridge.js';
test('recovery bridge preserves hash credentials for App only', () => {
  assert.equal(recoveryAppUrl('?source=app', '#type=recovery&access_token=fake-access&refresh_token=fake-refresh'), 'joybilliardsapp:///reset-password#type=recovery&access_token=fake-access&refresh_token=fake-refresh');
});
test('token hash and PKCE links are supported without redeeming tokens', () => {
  assert.equal(recoveryAppUrl('?type=recovery&token_hash=test', ''), 'joybilliardsapp:///reset-password?type=recovery&token_hash=test');
  assert.equal(recoveryAppUrl('?code=test', ''), 'joybilliardsapp:///reset-password?type=recovery&code=test');
});
test('missing, incomplete, wrong-type and error links cannot open recovery', () => {
  for (const [query, hash] of [['',''], ['?access_token=test',''], ['?type=signup&token_hash=test',''], ['?token_hash=test','#error=expired']]) assert.equal(recoveryAppUrl(query, hash), null);
});
