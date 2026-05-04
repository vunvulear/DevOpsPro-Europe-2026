# Brasov Sunset API

Simple Node.js/Express API that returns today's sunset time in Brasov, Romania using the local timezone (`Europe/Bucharest`).

## Setup

```bash
npm install
npm start
```

Server runs on `http://localhost:3000`.

## Endpoints

- `GET /` – info
- `GET /sunset` – today's sunset in Brasov

### Example response

```json
{
  "city": "Brasov",
  "country": "Romania",
  "timezone": "Europe/Bucharest",
  "date": "04.05.2026",
  "sunset_local": "20:38:12",
  "sunset_utc": "2026-05-04T17:38:12.000Z",
  "coordinates": { "latitude": 45.6427, "longitude": 25.5887 }
}
```

Sunset is computed with [`suncalc`](https://www.npmjs.com/package/suncalc).
