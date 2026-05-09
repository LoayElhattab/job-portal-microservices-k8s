const amqp = require('amqplib');

let channel;
const EXCHANGE_NAME = 'application_events';

const connectRabbitMQ = async () => {
  try {
    const connection = await amqp.connect(process.env.RABBITMQ_URL || 'amqp://localhost');
    channel = await connection.createChannel();

    await channel.assertExchange(EXCHANGE_NAME, 'topic', { durable: true });
    console.log(`✅ Connected to RabbitMQ. Exchange '${EXCHANGE_NAME}' asserted.`);
  } catch (error) {
    console.error('❌ Failed to connect to RabbitMQ:', error);
  }
};

const publishEvent = async (routingKey, payload) => {
  if (!channel) {
    console.error('RabbitMQ channel not initialized. Cannot publish event.');
    return;
  }
  try {
    channel.publish(
      EXCHANGE_NAME,
      routingKey,
      Buffer.from(JSON.stringify(payload)),
      { persistent: true }
    );
    console.log(`📤 Published event [${routingKey}]`);
  } catch (error) {
    console.error(`❌ Failed to publish event [${routingKey}]:`, error);
  }
};

module.exports = { connectRabbitMQ, publishEvent };
