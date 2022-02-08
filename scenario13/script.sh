#!/bin/bash

namespace="amazon"
contexts="cluster1 cluster2"

create(){
    for context in $contexts
    do
        kubectl --context $context create ns $namespace
        kubectl --context $context label ns $namespace istio-injection=enabled
    done

    kubectl --context cluster1 -n $namespace apply -f deployment-all.yaml
    kubectl --context cluster1 -n $namespace apply -f destination-rule.yaml -f virtualservice.yaml
    kubectl --context cluster1 -n $namespace apply -f virtualservicegateway.yaml
    kubectl --context cluster1 -n istio-system apply -f gateway.yaml
}

destroy() {
    #kubectl --context cluster1 -n istio-system delete -f gateway.yaml
    kubectl --context cluster1 -n $namespace delete -f virtualservicegateway.yaml
    kubectl --context cluster1 -n $namespace delete -f destination-rule.yaml -f virtualservice.yaml
    kubectl --context cluster1 -n $namespace delete -f deployment-all.yaml

    for context in $contexts
    do
        kubectl --context $context delete ns $namespace
    done
}

case "$1" in
    "") ;;
    create) "$@"; exit;;
    destroy) "$@"; exit;;
    *) log_error "Unkown function: $1()"; exit 2;;
esac
