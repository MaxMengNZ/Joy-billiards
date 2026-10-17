import { readFile } from 'node:fs/promises';
import { join } from 'node:path';
import { eventShareHtml, eventShareTarget } from './eventShareMetadata.js';

export function eventShareDev(loadEnv) {
  return {
    name: 'event-share-local-metadata',
    configureServer(server) {
      server.middlewares.use(async (req, res, next) => {
        const pathname = new URL(req.url, 'http://localhost').pathname;
        const isPreview = pathname === '/event-sharing-preview';
        if (!isPreview && !eventShareTarget(pathname)) return next();
        if (!['GET', 'HEAD'].includes(req.method)) return next();
        try {
          const file = isPreview ? 'server/eventSharingPreview.html' : 'index.html';
          let html = await readFile(join(server.config.root, file), 'utf8');
          if (!isPreview) {
            const env = loadEnv(server.config.mode, server.config.root, 'VITE_');
            html = (await eventShareHtml(html, pathname, env)).html;
          }
          // The standalone preview has no imports. Keep its inline script fresh instead
          // of creating Vite HTML-proxy entries for a virtual page on every edit.
          if (!isPreview) html = await server.transformIndexHtml(req.url, html);
          res.setHeader('Content-Type', 'text/html; charset=utf-8');
          res.setHeader('Cache-Control', 'private, no-store');
          res.end(req.method === 'HEAD' ? '' : html);
        } catch (error) { next(error); }
      });
    },
  };
}
