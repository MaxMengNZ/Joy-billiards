import assert from 'node:assert/strict'
import test from 'node:test'
import { readFileSync } from 'node:fs'
import { isDiscoverableEvent, orderPublicEvents, publicEventDate, publicEventFee, publicEventGroup, publicEventKind } from '../src/utils/publicEvents.js'
import { publicEventsQuery } from '../src/utils/publicEventsQuery.js'
const now = Date.parse('2026-10-17T00:00:00Z')
const event = (id, date, status = 'registration') => ({ id: `11111111-1111-4111-8111-${String(id).padStart(12, '0')}`, start_date: date, status })
test('ongoing first, then soonest; draft, cancelled, completed, invalid and stale entries excluded', () => {
  const late = event(1, '2026-12-25T00:00:00Z'), soon = event(2, '2026-10-18T00:00:00Z'), live = event(3, '2026-10-16T00:00:00Z', 'in_progress')
  assert.deepEqual(orderPublicEvents([late, soon, live, event(4, '2026-10-16T00:00:00Z'), event(5, 'invalid'), event(6, '2026-10-18', 'cancelled'), event(7, '2026-10-18', 'draft')], now), [live, soon, late])
  assert.equal(isDiscoverableEvent({ ...soon, id: 'not-a-uuid' }, now), false)
  assert.equal(publicEventGroup(live, now), 'live')
  assert.equal(publicEventGroup(soon, now), 'soon')
  assert.equal(publicEventGroup(late, now), 'later')
})
test('currency is explicit, free is real zero and missing values are never invented as free', () => {
  assert.match(publicEventFee({entry_fee:20,currency:'nzd'}), /NZD.*20/)
  assert.match(publicEventFee({entry_fee:'90.00'}, {currency:'AUD'}), /AUD.*90/)
  assert.equal(publicEventFee({entry_fee:0}), 'Free entry')
  for (const entry_fee of [null, undefined, '', -1, 'not-money']) assert.equal(publicEventFee({entry_fee}), 'Fee to be confirmed')
  assert.equal(publicEventFee({entry_fee:20}), 'See entry details')
})
test('dates use real venue timezone; missing timezone remains unknown', () => {
  const e = event(1, '2026-10-18T02:00:00Z')
  assert.match(publicEventDate(e, {timezone:'Pacific/Auckland'}, 'zh').date, /15:00/)
  assert.match(publicEventDate(e, {timezone:'Australia/Melbourne'}, 'zh').date, /13:00/)
  assert.equal(publicEventDate(e).zone, '')
  assert.equal(publicEventKind({event_options:{kind:'qualifier'}}), 'open')
})
test('overview preserves existing entry routes and reads public fields without writes or private data', () => {
  const route=readFileSync('src/router/index.js','utf8'), header=readFileSync('src/components/PublicClubHeader.vue','utf8'), page=readFileSync('src/views/PublicEventsPage.vue','utf8')
  assert.match(route, /path: '\/events'/)
  assert.match(route, /to.path === '\/events' && to.hash === '#event-list'/)
  assert.match(route, /path: '\/app\/e\/:reference'/)
  assert.match(route, /path: '\/app\/event\/:id'/)
  assert.match(header, /to="\/events"/)
  assert.match(page, /:to="eventSharePath\(event\)"/)
  assert.match(readFileSync('src/utils/publicEventsQuery.js','utf8'), /\.range\(offset, offset \+ EVENT_PAGE_SIZE - 1\)/)
  assert.match(page, /if \(seq !== request\) return/)
  assert.doesNotMatch(page, /\.insert\(|\.update\(|\.delete\(|\.rpc\(|from\(['"](?:users|user_venues|tournament_participants|tournament_entries)/)
})

function queryClient(rows) {
  return { from() {
    let filters=[], orders=[], bounds=[0,11]
    const value=(row,key)=>key==='event_options->>kind' ? row.event_options?.kind : row[key]
    const q={ select(){return q},eq(k,v){filters.push(r=>value(r,k)===v);return q},in(k,vs){filters.push(r=>vs.includes(value(r,k)));return q},gte(k,v){filters.push(r=>Date.parse(value(r,k))>=Date.parse(v));return q},or(expression){
      assert.equal(expression,'event_options->>kind.is.null,event_options->>kind.not.in.(weekly_pro,weekly_student,open,qualifier,individual)')
      filters.push(r=>publicEventKind(r)==='custom');return q
    },order(k){orders.push(k);return q},range(a,b){bounds=[a,b];return q},abortSignal(){return q},then(resolve){
      const data=rows.filter(r=>filters.every(f=>f(r))).sort((a,b)=>{for(const k of orders){const n=String(value(a,k)).localeCompare(String(value(b,k)));if(n)return n}return 0}).slice(bounds[0],bounds[1]+1)
      return Promise.resolve({data,error:null}).then(resolve)
    }};return q
  }}
}
test('first future page contains imminent upcoming event even with >12 distant registration events', async () => {
  const imminent=event(99,'2026-10-18T00:00:00Z','upcoming')
  const rows=[...Array.from({length:15},(_,i)=>event(i,'2026-12-25T00:00:00Z')),imminent,event(80,'2026-10-15T00:00:00Z','in_progress')]
  const client=queryClient(rows)
  const future=await publicEventsQuery(client,{live:false,now:new Date(now).toISOString()})
  const live=await publicEventsQuery(client,{live:true})
  assert.equal(future.data.length,12);assert.equal(future.data[0].id,imminent.id)
  assert.equal(live.data.length,1);assert.equal(live.data[0].status,'in_progress')
  const second=await publicEventsQuery(client,{live:false,offset:12,now:new Date(now).toISOString()})
  assert.equal(second.data.length,4)
})
test('Challenges & more query includes exactly the same missing and unknown kinds as its displayed category', async () => {
  const rows=['custom',null,'new-kind','weekly_pro','open'].map((kind,i)=>({...event(i,'2026-12-25T00:00:00Z'),event_options:{kind}}))
  const {data}=await publicEventsQuery(queryClient(rows),{live:false,kind:'custom',now:new Date(now).toISOString()})
  assert.deepEqual(data.map(r=>r.id),rows.filter(r=>publicEventKind(r)==='custom').map(r=>r.id))
})
