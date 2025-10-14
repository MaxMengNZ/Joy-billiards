# 🚢 Deployment Guide - Joy Billiards Tournament System

This guide covers deploying your tournament system to production.

---

## 📋 Pre-Deployment Checklist

- [ ] Database migration completed in Supabase
- [ ] All environment variables configured
- [ ] Application tested locally
- [ ] Production data backup plan established
- [ ] RLS policies reviewed for security

---

## 🌐 Deployment Options

### Option 1: Vercel (Recommended) ⭐

**Why Vercel?**
- Free tier available
- Automatic HTTPS
- Global CDN
- Zero configuration
- Git integration

**Steps:**

1. **Push to GitHub**
```bash
git init
git add .
git commit -m "Initial commit - Joy Billiards Tournament System"
git branch -M main
git remote add origin https://github.com/yourusername/joy-billiards.git
git push -u origin main
```

2. **Connect to Vercel**
- Go to https://vercel.com
- Click "Import Project"
- Select your GitHub repository
- Framework Preset: **Vite**

3. **Configure Environment Variables**
Add in Vercel dashboard:
```
VITE_SUPABASE_URL=https://qnwtqgdbgyqwpsdqvxfl.supabase.co
VITE_SUPABASE_ANON_KEY=your_actual_anon_key
```

4. **Deploy**
- Click "Deploy"
- Wait 2-3 minutes
- Your site will be live at `https://your-project.vercel.app`

5. **Custom Domain (Optional)**
- Go to Project Settings → Domains
- Add `joybilliards.co.nz` or your domain
- Configure DNS as instructed

---

### Option 2: Netlify

**Steps:**

1. **Push to GitHub** (same as above)

2. **Connect to Netlify**
- Go to https://netlify.com
- Click "Add new site" → "Import from Git"
- Select your repository

3. **Build Settings**
```
Build command: npm run build
Publish directory: dist
```

4. **Environment Variables**
Site Settings → Environment Variables:
```
VITE_SUPABASE_URL=https://qnwtqgdbgyqwpsdqvxfl.supabase.co
VITE_SUPABASE_ANON_KEY=your_actual_anon_key
```

5. **Deploy**
- Click "Deploy site"
- Live at `https://your-site.netlify.app`

---

### Option 3: Railway

**Steps:**

1. **Install Railway CLI**
```bash
npm install -g @railway/cli
```

2. **Login and Deploy**
```bash
railway login
railway init
railway up
```

3. **Add Environment Variables**
```bash
railway variables set VITE_SUPABASE_URL=https://qnwtqgdbgyqwpsdqvxfl.supabase.co
railway variables set VITE_SUPABASE_ANON_KEY=your_anon_key
```

---

### Option 4: Traditional VPS (DigitalOcean, AWS, etc.)

**Requirements:**
- Ubuntu 22.04 LTS server
- Node.js 18+
- Nginx
- SSL certificate

**Steps:**

1. **Build Locally**
```bash
npm run build
```

2. **Upload to Server**
```bash
scp -r dist/* user@your-server:/var/www/joy-billiards/
```

3. **Nginx Configuration**
```nginx
server {
    listen 80;
    server_name joybilliards.co.nz;
    root /var/www/joy-billiards;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    # Gzip compression
    gzip on;
    gzip_types text/plain text/css application/json application/javascript;
}
```

4. **SSL with Let's Encrypt**
```bash
sudo apt install certbot python3-certbot-nginx
sudo certbot --nginx -d joybilliards.co.nz
```

---

## 🔐 Production Security

### Update RLS Policies

For production, update Supabase RLS policies to restrict write access:

```sql
-- Drop open policies
DROP POLICY IF EXISTS "Allow all operations on players" ON players;
DROP POLICY IF EXISTS "Allow all operations on tournaments" ON tournaments;

-- Add admin-only policies
-- (Requires authentication setup first)

-- Example: Only authenticated users can write
CREATE POLICY "Authenticated users can write players" 
ON players FOR ALL 
USING (auth.role() = 'authenticated');
```

### Environment Variables Security
- Never commit `.env` file
- Use different keys for production vs development
- Rotate keys periodically
- Use Supabase service role key only on backend

### Additional Security Measures
1. **Enable Supabase RLS** (already done)
2. **Set up CORS** in Supabase settings
3. **Enable rate limiting** in Supabase
4. **Monitor logs** for suspicious activity
5. **Regular backups** of database

---

## 🎯 Post-Deployment

### 1. Test Production Site
- [ ] All pages load correctly
- [ ] Database connection works
- [ ] Can create players
- [ ] Can create tournaments
- [ ] Responsive on mobile
- [ ] SSL certificate valid

### 2. Set Up Monitoring

**Vercel Analytics** (Free)
- Automatically enabled on Vercel
- View at vercel.com/your-project/analytics

**Sentry Error Tracking** (Optional)
```bash
npm install @sentry/vue
```

### 3. Performance Optimization

**Enable Caching Headers**
Vercel/Netlify handle this automatically.

**Database Optimization**
- Add indexes (already in migration)
- Enable Supabase connection pooling
- Consider read replicas for high traffic

### 4. Backup Strategy

**Automatic Supabase Backups**
- Go to Supabase Project Settings → Database
- Enable Point-in-Time Recovery (paid plans)

**Manual Backup**
```bash
# From Supabase SQL Editor
pg_dump -h db.qnwtqgdbgyqwpsdqvxfl.supabase.co -U postgres > backup.sql
```

---

## 📊 Monitoring & Maintenance

### Weekly Tasks
- [ ] Check error logs
- [ ] Verify backups
- [ ] Review user feedback

### Monthly Tasks
- [ ] Database performance review
- [ ] Security audit
- [ ] Dependency updates: `npm update`

### Quarterly Tasks
- [ ] Full backup test restore
- [ ] RLS policy review
- [ ] Feature planning

---

## 🔄 CI/CD Pipeline

### GitHub Actions Example

Create `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: npm install
      - run: npm run build
      - uses: amondnet/vercel-action@v20
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
```

---

## 🚨 Troubleshooting

### Blank Page After Deploy
**Problem**: Site shows blank page in production

**Solution**:
1. Check browser console for errors
2. Verify environment variables are set
3. Ensure base path is correct in `vite.config.js`

### API Calls Failing
**Problem**: "Failed to fetch" errors

**Solutions**:
1. Check CORS settings in Supabase
2. Verify anon key is correct
3. Check browser network tab for actual error

### Slow Loading
**Problem**: Site takes too long to load

**Solutions**:
1. Enable Vercel/Netlify edge caching
2. Optimize images (if any added)
3. Check Supabase region (same as users)

---

## 📈 Scaling Considerations

### When to Upgrade

**Supabase Free → Pro:**
- More than 500MB database
- Need better performance
- Require daily backups

**Hosting Free → Paid:**
- Custom domain needed
- More than 100GB bandwidth/month
- Need team collaboration

### Performance Tips
- Use Supabase CDN for static assets
- Implement client-side caching
- Add pagination for large datasets
- Consider Edge Functions for complex queries

---

## 📞 Support Resources

- **Vercel Docs**: https://vercel.com/docs
- **Netlify Docs**: https://docs.netlify.com
- **Supabase Docs**: https://supabase.com/docs
- **Vue.js Docs**: https://vuejs.org

---

## ✅ Deployment Complete!

Your Joy Billiards Tournament System is now live! 🎱🎉

**Share your site:**
- With staff for testing
- On social media
- With local billiards community

**Next Steps:**
1. Monitor first week of usage
2. Gather user feedback
3. Plan feature enhancements
4. Enjoy managing tournaments!

---

**Questions about deployment?**
Contact Joy Billiards:
- 📞 022 166 0688
- 📍 88 Tristram Street, Hamilton Central

---

*Last updated: October 2025*


