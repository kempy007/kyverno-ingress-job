#!/bin/bash

fullSetup() {
    kubectl create -f https://raw.githubusercontent.com/NoSkillGirl/kyverno/bug/2395_GR_behaviour/definitions/release/install.yaml

    # kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

    kubectl apply -f ../rbac.kyverno.yaml
    kubectl create -f ./example-policy.yaml
    sleep 5
    kubectl apply -f ./ingress.yaml

    kubectl get jobs
    kubectl get pods
}

cleanup() {
    kubectl delete jobs --all 
    kubectl delete events --all
    kubectl delete -f ./ingress.yaml
}

refresh() {
    cleanup
    kubectl apply -f ./ingress.yaml
}

nuke() {
    cleanup
    kubectl delete -f ./example-policy.yaml 
    kubectl delete -f ../rbac.kyverno.yaml
    # kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
    kubectl delete -f https://raw.githubusercontent.com/NoSkillGirl/kyverno/bug/2395_GR_behaviour/definitions/release/install.yaml
}

runProgram() {
    echo "0 full setup"
    echo "1 clean"
    echo "2 clean and refresh"
    echo "9 Teardown"
    echo ""
    echo "Enter a value ( 0 | 1 | 2 | 9 )"
    read INP
    if [ "$INP" == "" ]
    then
        echo "No arguments supplied"
    fi

    if [ "$INP" == "0" ]
    then
        echo "Applying full setup"
        fullSetup
    fi

    if [ "$INP" == "1" ]
    then
        echo "Running Cleanup"
        cleanup
    fi

    if [ "$INP" == "2" ]
    then
        echo "Running Refresh"
        refresh
    fi

    if [ "$INP" == "9" ]
    then
        echo "Running Teardown"
        nuke
    fi
}


runProgram