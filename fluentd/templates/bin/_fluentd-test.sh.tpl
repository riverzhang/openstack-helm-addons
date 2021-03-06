#!/bin/bash

{{/*
Copyright 2017 The Openstack-Helm Authors.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/}}

set -ex

# Tests whether fluentd has successfully indexed data into Elasticsearch under
# the logstash-* index via the fluent-elasticsearch plugin
function check_logstash_index () {
  total_hits=$(curl -XGET "${ELASTICSEARCH_ENDPOINT}logstash-*/fluentd/_search?pretty" -H 'Content-Type: application/json' \
              | python -c "import sys, json; print json.load(sys.stdin)['hits']['total']")
  if [ "$total_hits" -gt 0 ]; then
     echo "PASS: Successful hits on logstash-* index, provided by fluentd!"
  else
     echo "FAIL: No hits on query for logstash-* index! Exiting";
     exit 1;
  fi
}

# Tests whether fluentd has successfully tagged data with the kubernetes.var.*
# prefix via the fluent-kubernetes plugin
function check_kubernetes_tag () {
  total_hits=$(curl -XGET "${ELASTICSEARCH_ENDPOINT}logstash-*/fluentd/_search?q=tag:kubernetes.var.*" -H 'Content-Type: application/json' \
              | python -c "import sys, json; print json.load(sys.stdin)['hits']['total']")
  if [ "$total_hits" -gt 0 ]; then
     echo "PASS: Successful hits on logstash-* index, provided by fluentd!"
  else
     echo "FAIL: No hits on query for logstash-* index! Exiting";
     exit 1;
  fi
}

check_logstash_index
check_kubernetes_tag
