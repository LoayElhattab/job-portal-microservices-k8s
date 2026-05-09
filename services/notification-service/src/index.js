require('dotenv').config();
const express = require('express');
const cors = require('cors');
const { connectWithRetry } = require('./db');
const { startConsumer } = require('../rabbitmq/consumer');
const notificationRoutes = require('./routes/notifications.routes');
const { errorHandler } = require('./middleware/errorHandler');
const { register, metricsMiddleware } = require('./metrics');

const app = express();
const PORT = process.env.PORT || 3003;

app.use(cors());
app.use(express.json());
app.use(metricsMiddleware);

// Routes
app.use('/api/v1/notifications', notificationRoutes);

// Health check
app.get('/health', (req, res) => res.status(200).json({ status: 'ok' }));

// Metrics endpoint
app.get('/metrics', async (req, res) => {
  try {
    res.set('Content-Type', register.contentType);
    res.end(await register.metrics());
  } catch (ex) {
    res.status(500).end(ex);
  }
});

// Error handling
app.use(errorHandler);

const startService = async () => {
  try {
    // 1. Connect to Database and run migrations
    await connectWithRetry();

    // 2. Start RabbitMQ consumer (only if not in test mode)
    if (process.env.NODE_ENV !== 'test') {
      await startConsumer();
    }

    // 3. Start Listening
    if (process.env.NODE_ENV !== 'test') {
      app.listen(PORT, () => {
        console.log(`Notification Service running on port ${PORT}`);
      });
    }
  } catch (error) {
    console.error('Failed to start service:', error);
    process.exit(1);
  }
};

if (process.env.NODE_ENV !== 'test') {
  startService();
}

module.exports = app;