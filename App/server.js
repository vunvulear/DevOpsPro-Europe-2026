// Optional Azure Application Insights auto-instrumentation.
// Activated only when APPLICATIONINSIGHTS_CONNECTION_STRING is set, so local
// development and tests never require the SDK or a connection.
if (process.env.APPLICATIONINSIGHTS_CONNECTION_STRING) {
  try {
    // eslint-disable-next-line global-require
    const appInsights = require('applicationinsights');
    appInsights
      .setup()
      .setAutoCollectConsole(true, true)
      .setSendLiveMetrics(false)
      .start();
  } catch (err) {
    // Do not crash the app if the optional dependency is missing.
    // eslint-disable-next-line no-console
    console.warn('applicationinsights not initialized:', err.message);
  }
}

const express = require('express');
const SunCalc = require('suncalc');

const app = express();
const PORT = process.env.PORT || 3000;
const APP_VERSION = process.env.APP_VERSION || 'dev';
const STARTED_AT = new Date().toISOString();

// Brasov, Romania coordinates
const BRASOV_LAT = 45.6427;
const BRASOV_LON = 25.5887;
const BRASOV_TZ = 'Europe/Bucharest';

app.get('/', (req, res) => {
  res.json({
    message: 'Brasov Sunset API',
    version: APP_VERSION,
    endpoints: ['/sunset', '/healthz', '/readyz']
  });
});

// Liveness probe — process is up.
app.get('/healthz', (req, res) => {
  res.json({ status: 'ok', uptime_s: process.uptime(), started_at: STARTED_AT });
});

// Readiness probe — dependencies look healthy. SunCalc is pure CPU, so we just
// verify it returns a finite Date for today.
app.get('/readyz', (req, res) => {
  try {
    const t = SunCalc.getTimes(new Date(), BRASOV_LAT, BRASOV_LON).sunset;
    if (!(t instanceof Date) || isNaN(t.getTime())) {
      return res.status(503).json({ status: 'not_ready', reason: 'suncalc_invalid' });
    }
    return res.json({ status: 'ready', version: APP_VERSION });
  } catch (err) {
    return res.status(503).json({ status: 'not_ready', reason: err.message });
  }
});

app.get('/sunset', (req, res) => {
  const now = new Date();
  const times = SunCalc.getTimes(now, BRASOV_LAT, BRASOV_LON);
  const sunset = times.sunset;

  const localSunset = sunset.toLocaleString('ro-RO', {
    timeZone: BRASOV_TZ,
    hour12: false
  });

  const localTime = sunset.toLocaleTimeString('ro-RO', {
    timeZone: BRASOV_TZ,
    hour12: false
  });

  const localDate = now.toLocaleDateString('ro-RO', {
    timeZone: BRASOV_TZ
  });

  res.json({
    city: 'Brasov',
    country: 'Romania',
    timezone: BRASOV_TZ,
    date: localDate,
    sunset_local: localTime,
    sunset_local_full: localSunset,
    sunset_utc: sunset.toISOString(),
    coordinates: { latitude: BRASOV_LAT, longitude: BRASOV_LON }
  });
});

if (require.main === module) {
  app.listen(PORT, () => {
    console.log(`Brasov Sunset API listening on http://localhost:${PORT}`);
  });
}

module.exports = { app, BRASOV_LAT, BRASOV_LON, BRASOV_TZ };
