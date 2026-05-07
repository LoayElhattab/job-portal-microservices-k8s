const express = require('express');
const cors = require('cors');
const { connectWithRetry } = require('./db');
const { connectRabbitMQ } = require('./rabbitmq/publisher');
const applicationRoutes = require('./routes/applications');
const { errorHandler } = require('./middleware/errorHandler');
const { register, metricsMiddleware } = require('./metrics');

const app = express();
const PORT = process.env.PORT || 3002;

app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);

app.use('/api/v1/applications', applicationRoutes);

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/health', (req, res) => res.status(200).json({ status: 'UP' }));
app.use(errorHandler);

const startService = async () => {
  await connectWithRetry();
  await connectRabbitMQ();

  app.listen(PORT, () => {
    console.log(`🚀 Application Service running on port ${PORT}`);
  });
};

startService();