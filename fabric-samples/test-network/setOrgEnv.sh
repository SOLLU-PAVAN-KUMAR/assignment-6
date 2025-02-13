#!/bin/bash
#
# SPDX-License-Identifier: Apache-2.0




# default to using jio
ORG=${1:-jio}

# Exit on first error, print all commands.
set -e
set -o pipefail

# Where am I?
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." && pwd )"

ORDERER_CA=${DIR}/test-network/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem
PEER0_jio_CA=${DIR}/test-network/organizations/peerOrganizations/jio.example.com/tlsca/tlsca.jio.example.com-cert.pem
PEER0_airtel_CA=${DIR}/test-network/organizations/peerOrganizations/airtel.example.com/tlsca/tlsca.airtel.example.com-cert.pem
PEER0_ORG3_CA=${DIR}/test-network/organizations/peerOrganizations/org3.example.com/tlsca/tlsca.org3.example.com-cert.pem


if [[ ${ORG,,} == "jio" || ${ORG,,} == "digibank" ]]; then

   CORE_PEER_LOCALMSPID=jioMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/jio.example.com/users/Admin@jio.example.com/msp
   CORE_PEER_ADDRESS=localhost:7051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/jio.example.com/tlsca/tlsca.jio.example.com-cert.pem

elif [[ ${ORG,,} == "airtel" || ${ORG,,} == "magnetocorp" ]]; then

   CORE_PEER_LOCALMSPID=airtelMSP
   CORE_PEER_MSPCONFIGPATH=${DIR}/test-network/organizations/peerOrganizations/airtel.example.com/users/Admin@airtel.example.com/msp
   CORE_PEER_ADDRESS=localhost:9051
   CORE_PEER_TLS_ROOTCERT_FILE=${DIR}/test-network/organizations/peerOrganizations/airtel.example.com/tlsca/tlsca.airtel.example.com-cert.pem

else
   echo "Unknown \"$ORG\", please choose jio/Digibank or airtel/Magnetocorp"
   echo "For example to get the environment variables to set upa airtel shell environment run:  ./setOrgEnv.sh airtel"
   echo
   echo "This can be automated to set them as well with:"
   echo
   echo 'export $(./setOrgEnv.sh airtel | xargs)'
   exit 1
fi

# output the variables that need to be set
echo "CORE_PEER_TLS_ENABLED=true"
echo "ORDERER_CA=${ORDERER_CA}"
echo "PEER0_jio_CA=${PEER0_jio_CA}"
echo "PEER0_airtel_CA=${PEER0_airtel_CA}"
echo "PEER0_ORG3_CA=${PEER0_ORG3_CA}"

echo "CORE_PEER_MSPCONFIGPATH=${CORE_PEER_MSPCONFIGPATH}"
echo "CORE_PEER_ADDRESS=${CORE_PEER_ADDRESS}"
echo "CORE_PEER_TLS_ROOTCERT_FILE=${CORE_PEER_TLS_ROOTCERT_FILE}"

echo "CORE_PEER_LOCALMSPID=${CORE_PEER_LOCALMSPID}"
