#!/bin/bash

function createjio() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/jio.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/jio.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-jio --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-jio.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-jio.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-jio.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-jio.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/jio.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy jio's CA cert to jio's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/jio.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/jio/ca-cert.pem" "${PWD}/organizations/peerOrganizations/jio.example.com/msp/tlscacerts/ca.crt"

  # Copy jio's CA cert to jio's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/jio.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/jio/ca-cert.pem" "${PWD}/organizations/peerOrganizations/jio.example.com/tlsca/tlsca.jio.example.com-cert.pem"

  # Copy jio's CA cert to jio's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/jio.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/jio/ca-cert.pem" "${PWD}/organizations/peerOrganizations/jio.example.com/ca/ca.jio.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-jio --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-jio --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-jio --id.name jioadmin --id.secret jioadminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-jio -M "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/jio.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-jio -M "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/tls" --enrollment.profile tls --csr.hosts peer0.jio.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/jio.example.com/peers/peer0.jio.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-jio -M "${PWD}/organizations/peerOrganizations/jio.example.com/users/User1@jio.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/jio.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/jio.example.com/users/User1@jio.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://jioadmin:jioadminpw@localhost:7054 --caname ca-jio -M "${PWD}/organizations/peerOrganizations/jio.example.com/users/Admin@jio.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/jio/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/jio.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/jio.example.com/users/Admin@jio.example.com/msp/config.yaml"
}

function createairtel() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/airtel.example.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/airtel.example.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-airtel --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airtel.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airtel.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airtel.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-airtel.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/airtel.example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy airtel's CA cert to airtel's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/peerOrganizations/airtel.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem" "${PWD}/organizations/peerOrganizations/airtel.example.com/msp/tlscacerts/ca.crt"

  # Copy airtel's CA cert to airtel's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/airtel.example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem" "${PWD}/organizations/peerOrganizations/airtel.example.com/tlsca/tlsca.airtel.example.com-cert.pem"

  # Copy airtel's CA cert to airtel's /ca directory (for use by clients)
  mkdir -p "${PWD}/organizations/peerOrganizations/airtel.example.com/ca"
  cp "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem" "${PWD}/organizations/peerOrganizations/airtel.example.com/ca/ca.airtel.example.com-cert.pem"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-airtel --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-airtel --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-airtel --id.name airteladmin --id.secret airteladminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-airtel -M "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/airtel.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-airtel -M "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/tls" --enrollment.profile tls --csr.hosts peer0.airtel.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the peer's tls directory that are referenced by peer startup config
  cp "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/airtel.example.com/peers/peer0.airtel.example.com/tls/server.key"

  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-airtel -M "${PWD}/organizations/peerOrganizations/airtel.example.com/users/User1@airtel.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/airtel.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/airtel.example.com/users/User1@airtel.example.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://airteladmin:airteladminpw@localhost:8054 --caname ca-airtel -M "${PWD}/organizations/peerOrganizations/airtel.example.com/users/Admin@airtel.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/airtel/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/airtel.example.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/airtel.example.com/users/Admin@airtel.example.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/example.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/example.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml"

  # Since the CA serves as both the organization CA and TLS CA, copy the org's root cert that was generated by CA startup into the org level ca and tlsca directories

  # Copy orderer org's CA cert to orderer org's /msp/tlscacerts directory (for use in the channel MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  # Copy orderer org's CA cert to orderer org's /tlsca directory (for use by clients)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/tlsca"
  cp "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem" "${PWD}/organizations/ordererOrganizations/example.com/tlsca/tlsca.example.com-cert.pem"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates, use --csr.hosts to specify Subject Alternative Names"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls" --enrollment.profile tls --csr.hosts orderer.example.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  # Copy the tls CA cert, server cert, server keystore to well known file names in the orderer's tls directory that are referenced by orderer startup config
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/server.key"

  # Copy orderer org's CA cert to orderer's /msp/tlscacerts directory (for use in the orderer MSP definition)
  mkdir -p "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/example.com/orderers/orderer.example.com/msp/tlscacerts/tlsca.example.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/ca-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/example.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/example.com/users/Admin@example.com/msp/config.yaml"
}
