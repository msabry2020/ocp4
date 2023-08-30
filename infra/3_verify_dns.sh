#!/bin/bash

    bootstrap_record=bootstrap.plz-vmware-sit-c01.nbe.ahly.bank
    bastion_record=bastion.plz-vmware-sit-c01.nbe.ahly.bank
    registry_record=registry.plz-vmware-sit-c01.nbe.ahly.bank
    master1=master01.plz-vmware-sit-c01.nbe.ahly.bank
    master2=master02.plz-vmware-sit-c01.nbe.ahly.bank
    master3=master03.plz-vmware-sit-c01.nbe.ahly.bank
    worker1=worker01.plz-vmware-sit-c01.nbe.ahly.bank
    worker2=worker02.plz-vmware-sit-c01.nbe.ahly.bank
    worker3=worker03.plz-vmware-sit-c01.nbe.ahly.bank
    storage=storage.plz-vmware-sit-c01.nbe.ahly.bank
    api_record=api.plz-vmware-sit-c01.nbe.ahly.bank
    api_int_record=api-int.plz-vmware-sit-c01.nbe.ahly.bank
    infra_record=infra.plz-vmware-sit-c01.nbe.ahly.bank
    wildcard_routes_record=*.apps.plz-vmware-sit-c01.nbe.ahly.bank

    success_count=0
    failed_records=""

    check_dns_resolution() {
        local record=$1
        local ip=$(dig +short "$record" | awk 'NR==1')

        if [[ -n "$ip" ]]; then
            ((success_count++))
            echo "Forward DNS resolution succeeded for $record: $ip"
            
            reverse_lookup=$(dig +short -x "$ip" | awk 'NR==1')
            if [[ -n "$reverse_lookup" ]]; then
                echo "Reverse DNS lookup succeeded for $ip: $reverse_lookup"
            else
                echo "Reverse DNS lookup failed for $ip"
            fi
        else
            failed_records+="$record "
            echo "Forward DNS resolution failed for $record"
        fi
    }

    echo "Validating DNS configuration..."

    echo "Performing forward DNS resolution..."
    echo

    check_dns_resolution "$bootstrap_record"
    echo "-------------------------------------"

    check_dns_resolution "$bastion_record"
    echo "-------------------------------------"

    check_dns_resolution "$registry_record"
    echo "-------------------------------------"
    
    check_dns_resolution "$infra_record"
    echo "-------------------------------------"

    check_dns_resolution "$master1"
    echo "-------------------------------------"

    check_dns_resolution "$master2"
    echo "-------------------------------------"

    check_dns_resolution "$master3"
    echo "-------------------------------------"

    check_dns_resolution "$worker1"
    echo "-------------------------------------"

    check_dns_resolution "$worker2"
    echo "-------------------------------------"

    check_dns_resolution "$worker3"
    echo "-------------------------------------"

    check_dns_resolution "$storage"
    echo "-------------------------------------"

    check_dns_resolution "$api_record"
    echo "-------------------------------------"

    check_dns_resolution "$api_int_record"
    echo "-------------------------------------"

    check_dns_resolution "$wildcard_routes_record"
    echo "-------------------------------------"

    echo
    echo "DNS configuration validation complete."
    echo "Succeeded records: $success_count"
    echo "Failed records: $failed_records"
