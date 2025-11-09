# Complete Next.js Deployment with Docker, Nginx & SSL

This setup provides a **one-command deployment** for your Next.js application with automatic SSL certificates and Nginx reverse proxy.

## 📋 Prerequisites

1. **Server with Docker & Docker Compose installed**
   - Ubuntu/Debian: `sudo apt update && sudo apt install docker.io docker-compose`
   - Or use Docker's official installation script

2. **Domain DNS Configuration** (MUST be done before deployment)
   - Point your domain's A record to your server's IP address
   - Add both root domain and www subdomain:
     - `theabhipatel.com` → Your Server IP
     - `www.theabhipatel.com` → Your Server IP
   - Wait for DNS propagation (5-30 minutes)

3. **Open Firewall Ports**
   ```bash
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   sudo ufw allow 22/tcp
   ```

## 📁 Project Structure

```
your-nextjs-app/
├── .env                          # Environment variables (domain & email)
├── .dockerignore                 # Files to exclude from Docker build
├── Dockerfile                    # Next.js app container
├── docker-compose.yml            # Orchestrates all services
├── init-letsencrypt.sh          # SSL initialization script
├── next.config.js               # Next.js configuration (needs update)
├── nginx/
│   ├── nginx.conf               # Main Nginx configuration
│   └── conf.d/
│       └── default.conf         # Server block with SSL
└── (your Next.js app files)
```

## 🔧 Step-by-Step Deployment

### Step 1: Update Next.js Configuration

**IMPORTANT:** Add this to your `next.config.js`:

```javascript
/** @type {import('next').NextConfig} */
const nextConfig = {
  output: 'standalone', // Required for Docker deployment
  // ... your other config
}

module.exports = nextConfig
```

### Step 2: Create Configuration Files

Copy all the provided configuration files to your project:
- `.env`
- `Dockerfile`
- `.dockerignore`
- `docker-compose.yml`
- `init-letsencrypt.sh`
- `nginx/nginx.conf`
- `nginx/conf.d/default.conf`

### Step 3: Update Environment Variables

The `.env` file is already configured with your domain and email:
```bash
DOMAIN=theabhipatel.com
EMAIL=hello@theabhipatel.com
STAGING=0
```

**For testing:** Set `STAGING=1` to use Let's Encrypt staging (avoid rate limits)

### Step 4: Make Init Script Executable

```bash
chmod +x init-letsencrypt.sh
```

### Step 5: Deploy with One Command! 🚀

```bash
./init-letsencrypt.sh
```

That's it! This script will:
1. ✅ Build your Next.js application
2. ✅ Start Nginx reverse proxy
3. ✅ Request SSL certificates from Let's Encrypt
4. ✅ Configure HTTPS with auto-renewal
5. ✅ Make your site live at `https://theabhipatel.com`

## 🔄 Daily Operations

### View Running Containers
```bash
docker-compose ps
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f nextjs
docker-compose logs -f nginx
docker-compose logs -f certbot
```

### Stop Services
```bash
docker-compose down
```

### Restart Services
```bash
docker-compose restart
```

### Update Your Application
```bash
# Pull latest code
git pull

# Rebuild and restart
docker-compose up -d --build
```

## 🔒 SSL Certificate Management

### Certificates are Auto-Renewed
The Certbot container automatically renews certificates every 12 hours (if needed).

### Manual Certificate Renewal
```bash
docker-compose run --rm certbot renew
docker-compose exec nginx nginx -s reload
```

### Certificate Location
Certificates are stored in: `./certbot/conf/live/theabhipatel.com/`

## 🐛 Troubleshooting

### Issue: "Certificate not found"
- Ensure DNS is properly configured and propagated
- Check: `dig theabhipatel.com` should show your server IP
- Try staging mode first: Set `STAGING=1` in `.env`

### Issue: "Connection refused"
- Check if containers are running: `docker-compose ps`
- Check Nginx logs: `docker-compose logs nginx`
- Verify firewall: Ports 80 and 443 must be open

### Issue: Next.js build fails
- Ensure `output: 'standalone'` is in `next.config.js`
- Check build logs: `docker-compose logs nextjs`
- Verify all dependencies are in `package.json`

### Issue: Rate limit from Let's Encrypt
- Use staging mode: Set `STAGING=1` in `.env`
- Staging has higher limits for testing
- Once working, switch to production: `STAGING=0`

### Test SSL Configuration
Visit: https://www.ssllabs.com/ssltest/analyze.html?d=theabhipatel.com

## 🔐 Security Best Practices

1. **Keep Docker Updated**
   ```bash
   sudo apt update && sudo apt upgrade
   ```

2. **Use Secrets for Sensitive Data**
   - Never commit `.env` to Git
   - Add to `.gitignore`

3. **Enable Firewall**
   ```bash
   sudo ufw enable
   sudo ufw status
   ```

4. **Regular Backups**
   - Backup `./certbot/conf` directory
   - Backup your database (if any)

## 📊 What Happens Behind the Scenes

1. **init-letsencrypt.sh runs:**
   - Creates dummy SSL certificates
   - Starts Nginx with dummy certs
   - Requests real certificates from Let's Encrypt
   - Replaces dummy certs with real ones
   - Reloads Nginx

2. **Docker Compose orchestrates:**
   - **nextjs** container: Runs your app on internal port 3000
   - **nginx** container: Exposes ports 80/443, proxies to Next.js
   - **certbot** container: Manages SSL certificates, auto-renews

3. **SSL Auto-Renewal:**
   - Certbot checks every 12 hours
   - Renews if certificate expires within 30 days
   - Nginx reloads every 6 hours to pick up new certificates

## 🎉 Success Indicators

Your deployment is successful when:
- ✅ `https://theabhipatel.com` loads your site
- ✅ `http://theabhipatel.com` redirects to HTTPS
- ✅ Browser shows padlock icon (secure connection)
- ✅ SSL certificate is valid and from Let's Encrypt
- ✅ All containers show as "Up" in `docker-compose ps`

## 🆘 Need Help?

Check logs in this order:
1. `docker-compose logs nginx` - Reverse proxy issues
2. `docker-compose logs nextjs` - Application issues
3. `docker-compose logs certbot` - SSL certificate issues

---

**🎊 Congratulations!** Your Next.js app is now deployed with automatic HTTPS! 🎊