const amqp = require('amqplib');
const { pool } = require('../db');

const EXCHANGE_NAME = 'application_events';
const QUEUE_NAME = 'notification_queue';

const startConsumer = async () => {
  try {
    const connection = await amqp.connect(process.env.RABBITMQ_URL || 'amqp://localhost');
    const channel = await connection.createChannel();

    await channel.assertExchange(EXCHANGE_NAME, 'topic', { durable: true });

    await channel.assertQueue(QUEUE_NAME, { durable: true });

    await channel.bindQueue(QUEUE_NAME, EXCHANGE_NAME, 'application.*');

    console.log(`🎧 Notification Service listening for events on queue: ${QUEUE_NAME}`);

    channel.consume(QUEUE_NAME, async (msg) => {
      if (msg !== null) {
        const routingKey = msg.fields.routingKey;
        const payload = JSON.parse(msg.content.toString());

        console.log(`📥 Received event [${routingKey}]`, payload);

        try {
          await processEvent(routingKey, payload);
          channel.ack(msg);
        } catch (dbError) {
          console.error('❌ Error processing event into DB:', dbError);
        }
      }
    });
  } catch (error) {
    console.error('❌ Failed to start RabbitMQ consumer:', error);
  }
};

const processEvent = async (routingKey, payload) => {
  let userId, message;

  if (routingKey === 'application.submitted') {
    userId = payload.employerId;
    message = `A new application has been submitted for your job posting (Job ID: ${payload.jobId}).`;
  }
  else if (routingKey === 'application.status_changed') {
    userId = payload.seekerId;
    message = `The status of your application for Job ID: ${payload.applicationId} has been updated to '${payload.newStatus}'.`;
  }
  else {
    return;
  }

  const insertQuery = `
    INSERT INTO notifications (user_id, message)
    VALUES ($1, $2);
  `;
  await pool.query(insertQuery, [userId, message]);
  console.log(`✅ Notification saved for User ID: ${userId}`);
};

module.exports = { startConsumer };