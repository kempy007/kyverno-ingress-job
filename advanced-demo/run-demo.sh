#!/bin/bash

fullSetup() {
    kubectl create ns bad-apps
    kubectl create ns cs-scans 
#    kubectl create -f https://raw.githubusercontent.com/NoSkillGirl/kyverno/bug/2395_GR_behaviour/definitions/release/install.yaml
    kubectl create -f https://raw.githubusercontent.com/kyverno/kyverno/v1.5.2/definitions/release/install.yaml

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml

    kubectl apply -f ./target-apps.yaml

    kubectl apply -f ../rbac.kyverno.yaml
    kubectl create -f ./nuclei-example-policy.yaml
    kubectl create -f ./zap-example-policy.yaml

    external_ip=""
    while [ -z $external_ip ]; do
        sleep 10
        external_ip=$(kubectl get svc ingress-nginx-controller -n ingress-nginx  --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
    done
    yq w -i ./dvwa-ingress.yaml "spec.rules[0].host" "$(echo dvwa.$external_ip.nip.io)"
    kubectl apply -f ./dvwa-ingress.yaml

    yq w -i ./webgoat-ingress.yaml "spec.rules[0].host" "$(echo webgoat.$external_ip.nip.io)"
    kubectl apply -f ./webgoat-ingress.yaml

    kubectl -n cs-scans get jobs
    kubectl -n cs-scans get pods
}

cleanup() {
    kubectl -n cs-scans delete jobs --all 
#    kubectl -n cs-scans delete pods --all
    kubectl delete -f ./dvwa-ingress.yaml
    kubectl delete -f ./webgoat-ingress.yaml
}

refresh() {
    cleanup
    kubectl apply -f ./dvwa-ingress.yaml
    kubectl apply -f ./webgoat-ingress.yaml
}

nuke() {
    cleanup
    # kubectl delete -f ./webgoat-ingress.yaml
    # kubectl delete -f ./dvwa-ingress.yaml 
    kubectl delete -f ./nuclei-example-policy.yaml
    kubectl delete -f ./zap-example-policy.yaml 
    kubectl delete -f ../rbac.kyverno.yaml
    kubectl delete -f ./target-apps.yaml
    kubectl delete -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/cloud/deploy.yaml
    kubectl delete -f https://raw.githubusercontent.com/NoSkillGirl/kyverno/bug/2395_GR_behaviour/definitions/release/install.yaml
    kubectl delete ns bad-apps
    kubectl delete ns cs-scans
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
