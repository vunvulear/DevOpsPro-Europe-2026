const request = require('supertest');
const SunCalc = require('suncalc');
const { app, BRASOV_LAT, BRASOV_LON, BRASOV_TZ } = require('brasov-sunset-api');

describe('Brasov Sunset API', () => {
  describe('Constants', () => {
    test('Brasov latitude is correct', () => {
      expect(BRASOV_LAT).toBeCloseTo(45.6427, 3);
    });

    test('Brasov longitude is correct', () => {
      expect(BRASOV_LON).toBeCloseTo(25.5887, 3);
    });

    test('timezone is Europe/Bucharest', () => {
      expect(BRASOV_TZ).toBe('Europe/Bucharest');
    });
  });

  describe('GET /', () => {
    test('returns 200 and info payload', async () => {
      const res = await request(app).get('/');
      expect(res.status).toBe(200);
      expect(res.body).toHaveProperty('message', 'Brasov Sunset API');
      expect(Array.isArray(res.body.endpoints)).toBe(true);
      expect(res.body.endpoints).toContain('/sunset');
    });

    test('returns JSON content-type', async () => {
      const res = await request(app).get('/');
      expect(res.headers['content-type']).toMatch(/application\/json/);
    });
  });

  describe('GET /sunset', () => {
    let res;

    beforeAll(async () => {
      res = await request(app).get('/sunset');
    });

    test('responds with 200', () => {
      expect(res.status).toBe(200);
    });

    test('returns city Brasov, Romania', () => {
      expect(res.body.city).toBe('Brasov');
      expect(res.body.country).toBe('Romania');
    });

    test('returns Europe/Bucharest timezone', () => {
      expect(res.body.timezone).toBe('Europe/Bucharest');
    });

    test('returns Brasov coordinates', () => {
      expect(res.body.coordinates.latitude).toBeCloseTo(BRASOV_LAT, 3);
      expect(res.body.coordinates.longitude).toBeCloseTo(BRASOV_LON, 3);
    });

    test('sunset_local matches HH:MM:SS format', () => {
      expect(res.body.sunset_local).toMatch(/^\d{2}:\d{2}:\d{2}$/);
    });

    test('sunset_utc is a valid ISO date', () => {
      const d = new Date(res.body.sunset_utc);
      expect(isNaN(d.getTime())).toBe(false);
    });

    test('sunset is for the current day in Brasov timezone', () => {
      const sunset = new Date(res.body.sunset_utc);
      const todayBrasov = new Date().toLocaleDateString('en-CA', { timeZone: BRASOV_TZ });
      const sunsetBrasov = sunset.toLocaleDateString('en-CA', { timeZone: BRASOV_TZ });
      expect(sunsetBrasov).toBe(todayBrasov);
    });

    test('sunset_utc matches SunCalc computation for Brasov', () => {
      const expected = SunCalc.getTimes(new Date(), BRASOV_LAT, BRASOV_LON).sunset;
      const actual = new Date(res.body.sunset_utc);
      // Allow tiny drift between computation moments
      expect(Math.abs(actual.getTime() - expected.getTime())).toBeLessThan(60 * 1000);
    });

    test('date field is present and non-empty', () => {
      expect(typeof res.body.date).toBe('string');
      expect(res.body.date.length).toBeGreaterThan(0);
    });
  });

  describe('GET /healthz', () => {
    test('returns 200 and ok status', async () => {
      const res = await request(app).get('/healthz');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('ok');
      expect(typeof res.body.uptime_s).toBe('number');
      expect(typeof res.body.started_at).toBe('string');
    });
  });

  describe('GET /readyz', () => {
    test('returns 200 and ready status', async () => {
      const res = await request(app).get('/readyz');
      expect(res.status).toBe(200);
      expect(res.body.status).toBe('ready');
    });
  });

  describe('Unknown routes', () => {
    test('returns 404 for unknown path', async () => {
      const res = await request(app).get('/does-not-exist');
      expect(res.status).toBe(404);
    });
  });
});
