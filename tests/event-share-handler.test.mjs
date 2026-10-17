import test from 'node:test';
import assert from 'node:assert/strict';
import handler from '../api/event-share.js';

const event={id:'5d14d9e5-799b-4ea0-837d-6d6397974a15',name:'Handler test',status:'registration',start_date:'2026-10-18T02:00:00Z',share_code:'FD1D51AD',venue_id:'hamilton-central',event_options:{}};
const response=()=>({headers:{},setHeader(key,value){this.headers[key]=value;},end(body=''){this.body=body;}});
test('production adapter keeps checkout query in browser, emits no redirect or private result, and disables CDN cache',async()=>{
  const originalFetch=globalThis.fetch;
  const originalUrl=process.env.VITE_SUPABASE_URL, originalKey=process.env.VITE_SUPABASE_ANON_KEY;
  process.env.VITE_SUPABASE_URL='https://example.supabase.co';process.env.VITE_SUPABASE_ANON_KEY='test-public';
  globalThis.fetch=async(url)=>Response.json([String(url).includes('/tournaments?')?event:{name:'JOY Hamilton',timezone:'Pacific/Auckland'}]);
  try{
    for(const path of ['/api/event-share','/app/e/FD1D51AD']){
      const res=response();
      await handler({url:`${path}?payment=success&checkout_session_id=cs_live_0123456789abcdef`,query:{eventKind:'e',eventRef:'FD1D51AD'},method:'GET',headers:{}},res);
      assert.equal(res.statusCode,200);assert.equal(res.headers.Location,undefined);
      assert.equal(res.headers['Vercel-CDN-Cache-Control'],undefined);
      assert.match(res.body,/og:title" content="Handler test/);
      assert.doesNotMatch(res.body,/cs_live_0123456789abcdef|test-public|已报名成功/);
      assert.match(res.body,/<div id="app"><\/div>/);
      assert.match(res.body,/src="\/assets\/index-/);
    }
    const publicRes=response();await handler({url:'/api/event-share?eventKind=e&eventRef=FD1D51AD',method:'GET',headers:{}},publicRes);
    assert.match(publicRes.headers['Vercel-CDN-Cache-Control'],/s-maxage=300/);
    const cookieRes=response();await handler({url:'/api/event-share?eventKind=e&eventRef=FD1D51AD',method:'GET',headers:{cookie:'session=not-forwarded'}},cookieRes);
    assert.equal(cookieRes.headers['Vercel-CDN-Cache-Control'],undefined);
    const head=response();await handler({url:'/api/event-share?eventKind=e&eventRef=FD1D51AD',method:'HEAD',headers:{}},head);assert.equal(head.body,'');
  }finally{
    globalThis.fetch=originalFetch;
    if(originalUrl===undefined)delete process.env.VITE_SUPABASE_URL;else process.env.VITE_SUPABASE_URL=originalUrl;
    if(originalKey===undefined)delete process.env.VITE_SUPABASE_ANON_KEY;else process.env.VITE_SUPABASE_ANON_KEY=originalKey;
  }
});
test('production adapter rejects POST without reaching a database',async()=>{
  const res=response();await handler({url:'/api/event-share/e/FD1D51AD',method:'POST',headers:{}},res);
  assert.equal(res.statusCode,405);assert.equal(res.headers.Allow,'GET, HEAD');
});
