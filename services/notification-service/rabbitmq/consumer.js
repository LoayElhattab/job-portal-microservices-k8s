const amqp = require('amqplib');
const { pool } = require('../src/db');

const RABBITMQ_URL = process.env.RABBITMQ_URL || 'amqp://localhost';
const EXCHANGE_NAME = 'application_events';
const QUEUE_NAME = 'notification_queue';

let connection = null;
let channel = null;

const connectWithRetry = async (retries = 10, delay = 5000) => {
  for (let i = 0; i < retries; i++) {
    try {
      connection = await amqp.connect(RABBITMQ_URL);
      channel = await connection.createChannel();
      
      await channel.assertExchange(EXCHANGE_NAME, 'topic', { durable: true });
      await channel.assertQueue(QUEUE_NAME, { durable: true });
      await channel.bindQueue(QUEUE_NAME, EXCHANGE_NAME, 'application.*');
      
      console.log('✅ Successfully connected to RabbitMQ (Notification Consumer)');
      return;
    } catch (err) {
      console.error(`⏳ RabbitMQ connection failed. Retrying in ${delay / 1000}s... (${i + 1}/${retries})`);
      await new Promise(res => setTimeout(res, delay));
    }
  }
  console.error('❌ Failed to connect to RabbitMQ after maximum retries.');
};

const startConsumer = async () => {
  if (!channel) await connectWithRetry();

  channel.consume(QUEUE_NAME, async (msg) => {
    if (msg !== null) {
      const content = JSON.parse(msg.content.toString());
      const routingKey = msg.fields.routingKey;

      console.log(`📩 Received event: ${routingKey}`, content);

      try {
        if (routingKey === 'application.submitted') {
          await pool.query(
            'INSERT INTO notifications (userId, type, message, relatedId) VALUES ($1, $2, $3, $4)',
            [
              content.employerId,
              'APPLICATION_RECEIVED',
              `New application received for job ID: ${content.jobId}`,
              content.applicationId
            ]
          );
        } else if (routingKey === 'application.status_changed') {
          await pool.query(
            'INSERT INTO notifications (userId, type, message, relatedId) VALUES ($1, $2, $3, $4)',
            [
              content.seekerId,
              'STATUS_UPDATED',
              `Your application status for application ID: ${content.applicationId} changed to ${content.newStatus}`,
              content.applicationId
            ]
          );
        }

        channel.ack(msg);
      } catch (error) {
        console.error('❌ Error processing message:', error);
        // Basic error handling: nack if it's a transient DB error, though simple ack is often safer to avoid infinite loops
        channel.nack(msg, false, true); 
      }
    }
  });
};

module.exports = { startConsumer };
