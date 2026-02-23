import os
import logging
import time
from celery import Celery



REDIS_URL = os.getenv("REDIS_URL", "redis://task-redis.bzjzq4.0001.aps1.cache.amazonaws.com:6379/0")

celery = Celery("worker", broker=REDIS_URL, backend=REDIS_URL)
celery.conf.broker_connection_retry_on_startup = True

logger = logging.getLogger(__name__)
logging.basicConfig(level=logging.INFO)

@celery.task
def write_log_celery(message: str):
    time.sleep(10)
    logger.info(f"[CELERY TASK] {message}")
    return f"Task completed: {message}"

