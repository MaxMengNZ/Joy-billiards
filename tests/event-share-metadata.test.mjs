import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { eventShareTarget, eventShareMetadata, injectEventShareMetadata, eventShareHtml, readEventShareMetadata } from '../server/eventShareMetadata.js';
const id = '5d14d9e5-799b-4ea0-837d-6d6397974a15';
const event = {id,name:'Student Tournament',start_date:'2026-10-18T02:00:00Z',status:'registration',venue_id:'hamilton-central',share_code:'FD1D51AD',event_options:{bannerUrl:'https://example.com/banner.jpg'}};
const venue = {name:'JOY Hamilton',address:'88 Tristram Street',timezone:'Pacific/Auckland'};
const template = '<html><head><title>Generic JOY</title><meta name="description" content="Generic"></head><body><div id="app"></div><script type="module" src="/assets/index-hash.js"></script></body></html>';
const env = {VITE_SUPABASE_URL:'https://example.supabase.co',VITE_SUPABASE_ANON_KEY:'public-test-key'};
const fetcher = async (url, options) => {
  assert.equal(options.method, 'GET');
  assert.equal(options.headers.Authorization, 'Bearer public-test-key');
  assert.equal(new URL(url).searchParams.get('limit'), '1');
  return Response.json([String(url).includes('/tournaments?') ? event : venue]);
};
test('both original links and internal routes are accepted; injection and non-event paths rejected', () => {
  for (const path of ['/app/e/FD1D51AD','/api/event-share/e/FD1D51AD']) assert.deepEqual(eventShareTarget(path), {kind:'e',value:'FD1D51AD'});
  assert.deepEqual(eventShareTarget(`/app/event/${id}`), {kind:'event',value:id});
  for (const path of ['/join','/events','/app/e/foo,bar','/app/e/a/b','/app/event/not-a-uuid','/app/e/%3Cscript%3E']) assert.equal(eventShareTarget(path),null);
});
test('real banner, title, venue and venue-local date appear in the initial HTML; body unchanged', () => {
  const metadata = eventShareMetadata(event,venue), html = injectEventShareMetadata(template,metadata);
  assert.match(metadata.description,/2026-10-18 15:00/);
  assert.match(metadata.description,/JOY Hamilton/);
  assert.equal(metadata.image,event.event_options.bannerUrl);
  for(const key of ['og:title','og:description','og:url','og:image','og:image:alt']) assert.ok(html.includes(key));
  assert.equal(html.split('<body>')[1],template.split('<body>')[1]);
  assert.equal((html.match(/<title>/g)||[]).length,1);
  assert.equal((html.match(/name="description"/g)||[]).length,1);
});
test('Melbourne time, completed/cancelled copy, fallback image and missing timezone are honest', () => {
  const zz = eventShareMetadata({...event,status:'completed',event_options:{}},{...venue,timezone:'Australia/Melbourne'});
  assert.match(zz.description,/2026-10-18 13:00/);
  assert.match(zz.description,/Event completed/);
  assert.match(zz.image,/icons\/icon-512x512.png$/);
  assert.match(eventShareMetadata({...event,status:'cancelled'},venue).description,/Event cancelled/);
  assert.match(eventShareMetadata(event,{}).description,/Date to be confirmed.*Venue to be confirmed/);
  assert.equal(eventShareMetadata({...event,status:'draft'},venue),null);
});
test('HTML injection is escaped and hostile images or tracking parameters cannot become canonical', async () => {
  const metadata=eventShareMetadata({...event,name:'<script>"&\'</script>',event_options:{bannerUrl:'javascript:alert(1)'}},venue);
  const html=injectEventShareMetadata(template,metadata);
  assert.match(html,/&lt;script&gt;/);
  assert.doesNotMatch(html,/<script>"|javascript:/);
  assert.equal(metadata.url,'https://club.joybilliards.co.nz/app/e/FD1D51AD');
  const result=await eventShareHtml(template,'/app/e/FD1D51AD',env,{fetcher});
  assert.equal(result.enriched,true);
  assert.doesNotMatch(result.html,/checkoutSessionId|checkout_session_id|payment=|public-test-key/);
});
test('only two public GETs; aliases normalized, no roster, auth, payment, or key forwarded to the page',async()=>{
  const calls=[];
  const data=await readEventShareMetadata({kind:'e',value:'fd1d51ad'},{env,fetcher:async(url,options)=>{calls.push(String(url));return fetcher(url,options);}});
  assert.equal(calls.length,2);
  assert.match(new URL(calls[0]).searchParams.get('or'),/share_code.eq.FD1D51AD/);
  assert.equal(data.title,event.name);
  assert.ok(calls.every(url=>!url.includes('users')&&!url.includes('registrations')&&!url.includes('/rpc/')));
});
test('missing env, invalid path, read failure and missing event keep the exact original SPA shell',async()=>{
  for(const [path,settings,fetcher] of [
    ['/app/e/FD1D51AD',{},()=>{throw Error('must not fetch');}],
    ['/join',env,()=>{throw Error('must not fetch');}],
    ['/app/e/FD1D51AD',env,async()=>{throw Error('offline');}],
    ['/app/e/FD1D51AD',env,async()=>Response.json([])],
  ]) assert.deepEqual(await eventShareHtml(template,path,settings,{fetcher}),{html:template,enriched:false});
});
test('routing changes only the two event links; payment return query is not part of rewrite destinations',async()=>{
  const config=JSON.parse(await readFile(new URL('../vercel.json',import.meta.url),'utf8'));
  const eventRules=config.rewrites.filter(rule=>rule.source.startsWith('/app/'));
  assert.deepEqual(eventRules,[{source:'/app/e/:reference',destination:'/api/event-share?eventKind=e&eventRef=:reference'},{source:'/app/event/:id',destination:'/api/event-share?eventKind=event&eventRef=:id'}]);
  assert.equal(config.functions['api/event-share.js'].includeFiles,'dist/index.html');
  const fallback=config.rewrites.find(rule=>rule.destination==='/index.html');
  const matcher=new RegExp(`^${fallback.source}$`);
  assert.equal(matcher.test('/api/event-share/e/FD1D51AD'),false);
  assert.equal(matcher.test('/api/event-share'),false);
  for(const path of ['/','/events','/join','/pricing','/membership','/verify-email']) assert.equal(matcher.test(path),true);
});
