import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
const source = (path) => readFile(new URL(`../src/${path}`, import.meta.url), 'utf8');

test('entry guidance is bilingual, explanatory and contains no data access or payment mutations', async () => {
  const guide = await source('components/EventEntryGuide.vue');
  for (const label of ['待支付', '转账待确认', '已确认', '已取消', 'Awaiting payment', 'Transfer awaiting confirmation', 'Confirmed', 'Cancelled']) assert.ok(guide.includes(label));
  assert.match(guide, /不是你的个人报名结果/);
  assert.match(guide, /不是|不代表报名成功/);
  assert.doesNotMatch(guide, /supabase|fetch\(|\.rpc\(|checkout_session_id|localStorage/);
  assert.match(guide, /v-if="canEnter && !paymentReturned"/);
  assert.match(guide, /role="status"/);
});
test('entry actions precede long rules and retain existing event and venue routes', async () => {
  const page = await source('views/TournamentEntrySharePage.vue');
  assert.ok(page.indexOf('<EventEntryGuide') < page.indexOf('<article class="details">'));
  assert.match(page, /eventAppRoute\(event\.value\.id, route\.query\)/);
  assert.match(page, /query: \{ event: event\.value\.id, venue: event\.value\.venue_id/);
  assert.match(page, /const path = eventSharePath\(event\.value\)/);
  assert.doesNotMatch(page, /\.(insert|update|upsert|delete)\(/);
});
test('account page keeps the event return link and verification flow without changing auth', async () => {
  const signup = await source('views/AppInviteRegisterPage.vue');
  assert.match(signup, /:to="`\/app\/event\/\$\{eventId\}`"/);
  assert.match(signup, /v-if="eventId" class="event-return-guide"/);
  assert.match(signup, /注册不会自动占位/);
  assert.match(signup, /verify-email\?event=/);
  assert.match(signup, /registration_venue_source: eventVenue\.value \? 'event_share'/);
});
