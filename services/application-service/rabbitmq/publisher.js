const amqp = require('amqplib');

let connection = null;
let channel = null;
const EXCHANGE_NAME = 'application_events';

const connectRabbitMQ = async () => {
  try {
    console.log('🔄 Connecting to RabbitMQ...');
    connection = await amqp.connect(process.env.RABBITMQ_URL || 'amqp://localhost');
    
    connection.on('error', (err) => {
      console.error('❌ RabbitMQ Connection error:', err.message);
    });

    connection.on('close', () => {
      console.error('❌ RabbitMQ Connection closed. Retrying reconnection in 5s...');
      channel = null;
      connection = null;
      setTimeout(connectRabbitMQ, 5000);
    });

    channel = await connection.createChannel();

    channel.on('error', (err) => {
      console.error('❌ RabbitMQ Channel error:', err.message);
    });

    channel.on('close', () => {
      console.log('❌ RabbitMQ Channel closed.');
      channel = null;
    });

    await channel.assertExchange(EXCHANGE_NAME, 'topic', { durable: true });
    console.log(`✅ Connected to RabbitMQ. Exchange '${EXCHANGE_NAME}' asserted.`);
  } catch (error) {
    console.error('❌ Failed to connect to RabbitMQ:', error.message);
    setTimeout(connectRabbitMQ, 5000);
  }
};

const publishEvent = async (routingKey, payload) => {
  if (!channel) {
    console.error(`⚠️ RabbitMQ channel not initialized. Cannot publish event [${routingKey}].`);
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
