const express = require('express');
const cors = require('cors');
const { connectWithRetry } = require('./db');
const { startConsumer } = require('./rabbitmq/consumer');
const notificationRoutes = require('./routes/notifications');
const { errorHandler } = require('./middleware/errorHandler');
const { register, metricsMiddleware } = require('./metrics');

const app = express();
const PORT = process.env.PORT || 3003;

app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);

app.use('/api/v1/notifications', notificationRoutes);

app.get('/metrics', async (req, res) => {
  res.set('Content-Type', register.contentType);
  res.end(await register.metrics());
});

app.get('/health', (req, res) => res.status(200).json({ status: 'UP' }));

app.use(errorHandler);

const startService = async () => {
  await connectWithRetry();

  await startConsumer();

  app.listen(PORT, () => {
    console.log(`🚀 Notification Service running on port ${PORT}`);
  });
};

startService();