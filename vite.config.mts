import { defineConfig } from 'vite'
import ViteRails from 'vite-plugin-rails'
import inject from "@rollup/plugin-inject";

export default defineConfig({
  plugins: [
    inject({   // => that should be first under plugins array
      $: 'jquery',
      jQuery: 'jquery',
    }),
    ViteRails({
      fullReload: {
        additionalPaths: ['app/components/**/*']
      }
    }),
  ],
  // Development server only. Allowing any host and origin lets HMR work when
  // the app is reached through a Tailscale MagicDNS name or another non-local
  // hostname. Asset requests still go through the Rails proxy; only the HMR
  // websocket connects to this server directly.
  server: {
    allowedHosts: true,
    cors: true,
    // The browser loads assets through Rails on port 3001, but the HMR
    // websocket connects straight to this server. Point the client at the
    // published dev-server port so it does not try port 3001 or localhost.
    ws: { clientPort: 3036 },
  },
  build: { sourcemap: false },
})
