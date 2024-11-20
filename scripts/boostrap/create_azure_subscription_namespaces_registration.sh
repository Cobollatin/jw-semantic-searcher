#!/bin/bash

NAMESPACES=("Microsoft.Batch")

for NAMESPACE in "${NAMESPACES[@]}"
do
    az provider register --namespace $NAMESPACE
done

echo "Azure subscription namespaces registered."