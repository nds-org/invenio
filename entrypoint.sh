#!/usr/bin/env bash

# Recreate the config files for the running services based on actual environment variables, instead of those set during docker build 
mkdir -p ../../var/${INVENIO_WEB_INSTANCE}-instance/
echo "# Database" > ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "SQLALCHEMY_DATABASE_URI='postgresql+psycopg2://${INVENIO_POSTGRESQL_DBUSER}:${INVENIO_POSTGRESQL_DBPASS}@${INVENIO_POSTGRESQL_HOST}:5432/${INVENIO_POSTGRESQL_DBNAME}'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Static file" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "COLLECT_STORAGE='flask_collect.storage.file'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Redis" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CACHE_TYPE='redis'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CACHE_REDIS_HOST='${INVENIO_REDIS_HOST}'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CACHE_REDIS_URL='redis://${INVENIO_REDIS_HOST}:6379/0'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "ACCOUNTS_SESSION_REDIS_URL='redis://${INVENIO_REDIS_HOST}:6379/1'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Celery" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "BROKER_URL='amqp://guest:guest@${INVENIO_RABBITMQ_HOST}:5672//'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CELERY_RESULT_BACKEND='redis://${INVENIO_REDIS_HOST}:6379/2'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CELERY_ACCEPT_CONTENT=['json', 'msgpack', 'yaml']" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Elasticsearch" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "SEARCH_ELASTIC_HOSTS='${INVENIO_ELASTICSEARCH_HOST}'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
RECORDS_REST_CONF=`cat <<EOF
try:
    from invenio_marc21.config import MARC21_REST_ENDPOINTS as RECORDS_REST_ENDPOINTS
except ImportError:
    import copy
    from invenio_records_rest.config import RECORDS_REST_ENDPOINTS as RRE
    RECORDS_REST_ENDPOINTS = copy.deepcopy(RRE)
    RECORDS_REST_ENDPOINTS['recid']['search_index'] = 'marc21'
EOF
`
echo "${RECORDS_REST_CONF}" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
RECORDS_UI_CONF=`cat <<EOF
RECORDS_UI_ENDPOINTS = dict(
    recid=dict(
      pid_type='recid',
      route='/records/<pid_value>',
      template='invenio_marc21/detail.html',
    ),
)
EOF
`
echo "${RECORDS_UI_CONF}" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
JSONSCHEMAS_CONF=`cat <<EOF
JSONSCHEMAS_ENDPOINT='/schema'
JSONSCHEMAS_HOST='${INVENIO_WEB_HOST}'
EOF
`
echo "${JSONSCHEMAS_CONF}" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "OAISERVER_RECORD_INDEX='marc21'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "OAISERVER_ID_PREFIX='oai:${INVENIO_WEB_INSTANCE}:recid/'" >> ../../var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg

/bin/bash -c invenio3 run -h 0.0.0.0
