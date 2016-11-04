#
# Not for general use; read the commands before running
#

NAME=storage.ucsc-cgl.org
KEY=artifacts/${NAME}.key
CSR=artifacts/${NAME}.csr
CRT=artifacts/${NAME}.crt
PKCS12=artifacts/${NAME}.p12
JKS=artifacts/${NAME}.jks
SERVER_TRUST=artifacts/cacerts
CLIENT_TRUST=artifacts/clientcacerts

PASSWORD=password1
SERVER_TRUST_PASSWORD=password2
CLIENT_TRUST_PASSWORD=password3

all: ${JKS} trust

${JKS}: jks

jks: ${PKCS12}
	keytool -importkeystore -srckeystore ${PKCS12} -srcstoretype pkcs12 -srcstorepass ${PASSWORD} -destkeystore ${JKS} -deststoretype jks -deststorepass ${PASSWORD}

${PKCS12}: pkcs12

pkcs12: ${CRT}
	openssl pkcs12 -inkey ${KEY} -passin pass:${PASSWORD} -in ${CRT} -export -out ${PKCS12}  -passout pass:${PASSWORD}

${CRT}: crt

crt: ${CSR}
	openssl x509 -signkey ${KEY} -passin pass:${PASSWORD} -in ${CSR} -req -days 365 -out ${CRT} -extfile openssl-cgl.cfg -extensions v3_req

${CSR}: csr

csr: artifacts
	openssl req -new -out ${CSR} -newkey rsa:4096 -keyout ${KEY} -passout pass:${PASSWORD} -config openssl-cgl.cfg

artifacts:
	mkdir artifacts

clean:
	- rm -r artifacts

view_csr: ${CSR}
	openssl req -text -noout -verify -in ${CSR}

view_crt: ${CRT}
	openssl x509 -text -noout -in ${CRT}

view_pkcs12: ${PKCS12}
	keytool -list -keystore ${PKCS12} -storepass ${PASSWORD} -storetype pkcs12 -v

view_jks: ${JKS}
	keytool -list -keystore ${JKS} -storepass ${PASSWORD} -v

trust: ${CRT} cacerts.raw artifacts
	cp cacerts.raw ${SERVER_TRUST}
	keytool -import -trustcacerts -keystore ${SERVER_TRUST} -storepass changeit -alias ${NAME} -file ${CRT}
	keytool -storepasswd -keystore ${SERVER_TRUST} -storepass changeit -new ${SERVER_TRUST_PASSWORD}
	cp ${SERVER_TRUST} ${CLIENT_TRUST}
	keytool -storepasswd -keystore ${CLIENT_TRUST} -storepass ${SERVER_TRUST_PASSWORD} -new ${CLIENT_TRUST_PASSWORD}
