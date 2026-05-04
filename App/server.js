const express = require('express');
const SunCalc = require('suncalc');

const app = express();
const PORT = process.env.PORT || 3000;

// Brasov, Romania coordinates
const BRASOV_LAT = 45.6427;
const BRASOV_LON = 25.5887;
const BRASOV_TZ = 'Europe/Bucharest';

app.get('/', (req, res) => {
  res.json({
    message: 'Brasov Sunset API',
    endpoints: ['/sunset']
  });
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
