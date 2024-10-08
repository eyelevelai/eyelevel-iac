from flask import Flask, request, jsonify

from redisClient import RedisClient
from minioClient import MinioClient
from kafkaAdmin import KafkaAdmin
from kafkaProducer import KafkaProducer
from kafkaConsumer import KafkaConsumer

app = Flask(__name__)

@app.route("/", methods=["GET"])
def hello_world():
    return "Admin server is working", 200

@app.route("/modules", methods=["GET"])
def get_modules():
    redis_client = RedisClient()
    minio_client = MinioClient()
    kafka_admin = KafkaAdmin()
    kafka_healthy, kafka_error = kafka_admin.health_check()
    return jsonify({
        "redis": "Healthy" if redis_client.health_check() else "Unhealthy",
        "minio": "Healthy" if minio_client.health_check() else "Unhealthy",
        "kafka": "Healthy" if kafka_healthy else f"Unhealthy: {kafka_error}",
    }), 200

@app.route("/redis/list", methods=["GET", "POST"])
def redis_list():
    redis_client = RedisClient()
    try:
        return jsonify(redis_client.list_keys()), 200
    except Exception as e:
        return str(e), 500

@app.route("/redis/get", methods=["GET", "POST"])
def redis_get():
    redis_client = RedisClient()
    req_body = request.get_json()
    key = req_body.get("key")
    if not key:
        return "Key is required", 400
    try:
        value = redis_client.get(key)
        if not value:
            return "Key not found", 404
        return value, 200
    except Exception as e:
        return str(e), 500

@app.route("/redis/set", methods=["POST"])
def redis_set():
    redis_client = RedisClient()
    req_body = request.get_json()
    key = req_body.get("key")
    value = req_body.get("value")
    if not key or not value:
        return "Key and value are required", 400
    try:
        redis_client.set(key, value)
        return "Key set successfully", 200
    except Exception as e:
        return str(e), 500

@app.route("/redis/delete", methods=["DELETE"])
def redis_delete():
    redis_client = RedisClient()
    req_body = request.get_json()
    key = req_body.get("key")
    if not key:
        return "Key is required", 400
    try:
        redis_client.delete(key)
        return "Key deleted successfully", 200
    except Exception as e:
        return str(e), 500

@app.route("/minio/buckets", methods=["GET"])
def minio_buckets():
    minio_client = MinioClient()
    try:
        return jsonify(minio_client.list_buckets()), 200
    except Exception as e:
        return str(e), 500

@app.route("/minio/upload", methods=["POST"])
def minio_upload():
    minio_client = MinioClient()
    req_body = request.get_json()
    file_name = req_body.get("file_name")
    file_content = req_body.get("file_content")
    file_type = req_body.get("file_type")
    bucket_name = req_body.get("bucket_name")
    if not file_name or not file_content or not file_type or not bucket_name:
        return "file_name, file_content, file_type, and bucket_name are required", 400
    try:
        minio_client.upload_file(file_name, file_content, file_type, bucket_name)
        return "File uploaded successfully", 200
    except Exception as e:
        return str(e), 500

@app.route("/minio/files", methods=["GET", "POST"])
def minio_files():
    minio_client = MinioClient()
    req_body = request.get_json()
    bucket_name = req_body.get("bucket_name")
    if not bucket_name:
        return "bucket_name is required", 400
    try:
        return jsonify(minio_client.list_files(bucket_name)), 200
    except Exception as e:
        return str(e), 500

@app.route("/minio/read", methods=["POST"])
def minio_read_file():
    minio_client = MinioClient()
    req_body = request.get_json()
    file_name = req_body.get("file_name")
    bucket_name = req_body.get("bucket_name")
    if not file_name or not bucket_name:
        return "file_name and bucket_name are required", 400
    try:
        res = minio_client.read_file(file_name, bucket_name)
        return res if res else "", 200
    except Exception as e:
        return str(e), 500

@app.route("/minio/file", methods=["DELETE"])
def minio_delete_file():
    minio_client = MinioClient()
    req_body = request.get_json()
    file_name = req_body.get("file_name")
    bucket_name = req_body.get("bucket_name")
    if not file_name or not bucket_name:
        return "file_name and bucket_name are required", 400
    try:
        minio_client.delete_file(file_name, bucket_name)
        return "File deleted successfully", 200
    except Exception as e:
        return str(e), 500

@app.route("/minio/bucket", methods=["DELETE"])
def minio_delete_bucket():
    minio_client = MinioClient()
    req_body = request.get_json()
    bucket_name = req_body.get("bucket_name")
    if not bucket_name:
        return "bucket_name is required", 400
    try:
        minio_client.delete_bucket(bucket_name)
        return "Bucket deleted successfully", 200
    except Exception as e:
        return str(e), 500

@app.route("/kafka/admin/topics", methods=["GET"])
def kafka_topics():
    kafka_client = KafkaAdmin()
    try:
        return jsonify(kafka_client.list_topics()), 200
    except Exception as e:
        return str(e), 500

@app.route("/kafka/admin/create-topic", methods=["POST"])
def kafka_create_topic():
    kafka_client = KafkaAdmin()
    req_body = request.get_json()
    topic = req_body.get("topic")
    if not topic:
        return "topic is required", 400
    try:
        kafka_client.create_topic(topic)
        return "Topic created successfully", 200
    except Exception as e:
        return str(e), 500

@app.route("/kafka/admin/delete-topic", methods=["DELETE"])
def kafka_delete_topic():
    kafka_client = KafkaAdmin()
    req_body = request.get_json()
    topic = req_body.get("topic")
    if not topic:
        return "topic is required", 400
    try:
        kafka_client.delete_topic(topic)
        return "Topic deleted successfully", 200
    except Exception as e:
        return str(e), 500

@app.route("/kafka/admin/describe-topic", methods=["POST"])
def kafka_describe_topic():
    kafka_client = KafkaAdmin()
    req_body = request.get_json()
    topic = req_body.get("topic")
    if not topic:
        return "topic is required", 400
    try:
        return jsonify(kafka_client.describe_topic(topic)), 200
    except Exception as e:
        return str(e), 500

@app.route("/kafka/produce", methods=["POST"])
def kafka_produce():
    kafka_client = KafkaProducer()
    req_body = request.get_json()
    topic = req_body.get("topic")
    key = req_body.get("key")
    value = req_body.get("value")
    if not topic or not key or not value:
        return "topic and message are required", 400
    try:
        kafka_client.send_message(topic, key, value)
        return "Message produced successfully", 200
    except Exception as e:
        return str(e), 500
    finally:
        kafka_client.close()

@app.route("/kafka/consume", methods=["POST"])
def kafka_consume():
    req_body = request.get_json()
    topic = req_body.get("topic")
    group_id = req_body.get("group_id")
    auto_offset_reset = req_body.get("auto_offset_reset")
    if not topic or not group_id or not auto_offset_reset:
        return "topic is required", 400
    kafka_client = KafkaConsumer(topic, group_id, auto_offset_reset)
    try:
        return jsonify(kafka_client.consume_messages()), 200
    except Exception as e:
        return str(e), 500
    finally:
        kafka_client.close()



if __name__ == "__main__":
    app.run(host='0.0.0.0', port=8080, debug=True)
