#
# Not for general use; read the commands before running
#

NAME=storage.ucsc-cgl.org
KEY=artifacts/${NAME}.key
CSR=artifacts/${NAME}.csr
CRT=artifacts/${NAME}.crt
PKCS12=artifacts/${NAME}.p12
JKS=artifacts/${NAME}.jks
TRUST=artifacts/cacerts

PASSWORD=password
TRUST_PASSWORD=changeit

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

trust: ${TRUST} ${CRT}
	keytool -import -trustcacerts -keystore ${TRUST} -storepass ${TRUST_PASSWORD} -alias ${NAME} -file ${CRT}

${TRUST}: cacerts.raw artifacts
	cp cacerts.raw ${TRUST}
