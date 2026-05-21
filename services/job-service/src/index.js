const express = require('express');
const { connectWithRetry } = require('./db');
const { registry, metricsMiddleware } = require('./metrics');
const jobsRouter = require('./routes/jobs.routes');
const errorHandler = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3001;

app.use(express.json());
app.use(metricsMiddleware);

app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', registry.contentType);
  res.end(await registry.metrics());
});

app.use('/api/v1/jobs', jobsRouter);

app.use(errorHandler);

module.exports = app;

if (process.env.NODE_ENV !== 'test') {
  connectWithRetry()
    .then(() => {
      app.listen(PORT, () => console.log(`Job service running on port ${PORT}`));
    })
    .catch((err) => {
      console.error('Failed to connect to database:', err.message);
      process.exit(1);
    });
}
