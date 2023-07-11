export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/hutechorg.com/orderers/orderer.hutechorg.com/msp/tlscacerts/tlsca.hutechorg.com-cert.pem
export PEER0_ORG1_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hr.com/peers/peer0.hr.com/tls/ca.crt
export PEER0_ORG2_CA=${PWD}/artifacts/channel/crypto-config/peerOrganizations/employee.com/peers/peer0.employee.example.com/tls/ca.crt
export FABRIC_CFG_PATH=${PWD}/artifacts/channel/config/

export CHANNEL_NAME=hutechchannel

setGlobalsForOrderer(){
    export CORE_PEER_LOCALMSPID="OrdererMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/hutechorg.com/orderers/orderer.hutechorg.com/msp/tlscacerts/tlsca.hutechorg.com-cert.pem
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/ordererOrganizations/hutechorg.com/users/Admin@hutechorg.com/msp
    
}

setGlobalsForPeer0hr(){
    export CORE_PEER_LOCALMSPID="hrMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hr.com/users/Admin@hr.com/msp
    export CORE_PEER_ADDRESS=localhost:7051
}

setGlobalsForPeer1hr(){
    export CORE_PEER_LOCALMSPID="hrMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_HR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/hr.com/users/Admin@hr.com/msp
    export CORE_PEER_ADDRESS=localhost:8051
    
}

setGlobalsForPeer0employee(){
    export CORE_PEER_LOCALMSPID="employeeMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER1_EMPLOYEE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/employee.com/users/Admin@employee.com/msp
    export CORE_PEER_ADDRESS=localhost:9051
    
}

setGlobalsForPeer1employee(){
    export CORE_PEER_LOCALMSPID="employeeMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_EMPLOYEE_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/artifacts/channel/crypto-config/peerOrganizations/employee.com/users/Admin@employee.com/msp
    export CORE_PEER_ADDRESS=localhost:10051
    
}

createChannel(){
    rm -rf ./channel-artifacts/*
    setGlobalsForPeer0hr
    
    peer channel create -o localhost:7050 -c ${CHANNEL_NAME} \
    --ordererTLSHostnameOverride orderer.hutechorg.com \
    -f ./artifacts/channel/${CHANNEL_NAME}.tx --outputBlock ./channel-artifacts/${CHANNEL_NAME}.block \
    --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
}

removeOldCrypto(){
    rm -rf ./api-1.4/crypto/*
    rm -rf ./api-1.4/fabric-client-kv-hr/*
    rm -rf ./api-2.0/hr-wallet/*
    rm -rf ./api-2.0/employee-wallet/*
}


joinChannel(){
    setGlobalsForPeer0hr
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1hr
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer0employee
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
    setGlobalsForPeer1employee
    peer channel join -b ./channel-artifacts/$CHANNEL_NAME.block
    
}

updateAnchorPeers(){
    setGlobalsForPeer0hr
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.hutechorg.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
    setGlobalsForPeer0employee
    peer channel update -o localhost:7050 --ordererTLSHostnameOverride orderer.hutechorg.com -c $CHANNEL_NAME -f ./artifacts/channel/${CORE_PEER_LOCALMSPID}anchors.tx --tls $CORE_PEER_TLS_ENABLED --cafile $ORDERER_CA
    
}

removeOldCrypto

createChannel
# joinChannel
# updateAnchorPeers