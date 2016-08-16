#!/usr/bin/env bash

BASEDIR="/home/invenio/.virtualenvs/invenio3"
# Recreate the config files for the running services based on actual environment variables, instead of those set during docker build 
echo "# Database" > $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "SQLALCHEMY_DATABASE_URI='postgresql+psycopg2://${INVENIO_POSTGRESQL_DBUSER}:${INVENIO_POSTGRESQL_DBPASS}@${INVENIO_POSTGRESQL_HOST}:5432/${INVENIO_POSTGRESQL_DBNAME}'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Static file" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "COLLECT_STORAGE='flask_collect.storage.file'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Redis" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CACHE_TYPE='redis'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CACHE_REDIS_HOST='${INVENIO_REDIS_HOST}'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CACHE_REDIS_URL='redis://${INVENIO_REDIS_HOST}:6379/0'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "ACCOUNTS_SESSION_REDIS_URL='redis://${INVENIO_REDIS_HOST}:6379/1'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Celery" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "BROKER_URL='amqp://guest:guest@${INVENIO_RABBITMQ_HOST}:5672//'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CELERY_RESULT_BACKEND='redis://${INVENIO_REDIS_HOST}:6379/2'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "CELERY_ACCEPT_CONTENT=['json', 'msgpack', 'yaml']" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "# Elasticsearch" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "SEARCH_ELASTIC_HOSTS='${INVENIO_ELASTICSEARCH_HOST}'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
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
echo "${RECORDS_REST_CONF}" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
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
echo "${RECORDS_UI_CONF}" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
JSONSCHEMAS_CONF=`cat <<EOF
JSONSCHEMAS_ENDPOINT='/schema'
JSONSCHEMAS_HOST='${INVENIO_WEB_HOST}'
EOF
`
echo "${JSONSCHEMAS_CONF}" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "OAISERVER_RECORD_INDEX='marc21'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg
echo "OAISERVER_ID_PREFIX='oai:${INVENIO_WEB_INSTANCE}:recid/'" >> $BASEDIR/var/${INVENIO_WEB_INSTANCE}-instance/${INVENIO_WEB_INSTANCE}.cfg

invenio3 run -h 0.0.0.0
