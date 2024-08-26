from confluent_kafka import Consumer

class KafkaConsumer:
    def __init__(self, bootstrap_servers, group_id, topic):
        self.config = {
            'bootstrap.servers': bootstrap_servers,
            'group.id': group_id,
            'auto.offset.reset': 'earliest'
        }
        self.topic = topic
        self.consumer = Consumer(self.config)
        self.consumer.subscribe([self.topic])

    def consume_messages(self):
        try:
            while True:
                msg = self.consumer.poll(1.0)
                if msg is None:
                    yield "Waiting...\n"
                elif msg.error():
                    yield f"ERROR: {msg.error()}\n"
                else:
                    yield f"Consumed event from topic {msg.topic()}: key = {msg.key().decode('utf-8')} value = {msg.value().decode('utf-8')}\n"
        except KeyboardInterrupt:
            yield "Interrupted by user\n"
        finally:
            self.close()

    def close(self):
        self.consumer.close()
        print("Consumer closed")
