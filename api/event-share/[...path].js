import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { eventShareHtml } from '../../server/eventShareMetadata.js';

export default async function handler(req, res) {
  res.setHeader('Content-Type', 'text/html; charset=utf-8');
  res.setHeader('Cache-Control', 'private, no-store, max-age=0');
  if (!['GET', 'HEAD'].includes(req.method)) {
    res.setHeader('Allow', 'GET, HEAD');
    res.statusCode = 405;
    return res.end();
  }
  try {
    const template = await readFile(join(process.cwd(), 'dist/index.html'), 'utf8');
    const url = new URL(req.url, 'https://club.joybilliards.co.nz');
    const result = await eventShareHtml(template, url.pathname, process.env);
    // Public title/banner only; never CDN-cache checkout returns, auth queries or cookies.
    if (result.enriched && !url.search && !req.headers?.cookie && !req.headers?.authorization) {
      res.setHeader('Vercel-CDN-Cache-Control', 'public, s-maxage=300, stale-while-revalidate=60');
    }
    if (!result.enriched) console.warn('event-share: serving unchanged page without event metadata');
    res.statusCode = 200;
    return res.end(req.method === 'HEAD' ? '' : result.html);
  } catch {
    // Never redirect a checkout return to the home page or discard its event context.
    console.error('event-share: HTML template unavailable');
    res.statusCode = 503;
    res.setHeader('Retry-After', '5');
    return res.end('<!doctype html><meta charset="utf-8"><title>JOY CLUB</title><p>页面暂未载入，请刷新重试。Please refresh to retry.</p>');
  }
}
