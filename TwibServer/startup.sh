npm install
export SCOPE="public"
pm2 stop all
pm2 start server.mjs
pm2 logs
