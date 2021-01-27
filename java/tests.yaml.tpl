schemaVersion: "2.0.0"

commandTests:
- name: 'java-version'
  command: 'java'
  args: ['-version']
  # java outputs to stderr.
  expectedError: ["openjdk version \"1.8.*"]
- name: 'java11-version'
  command: '/usr/lib/jvm/{_JAVA_REVISION}/reduced/bin/java'
  args: ['-version']
  # java outputs to stderr.
  expectedError: ["openjdk version \"11.*"]
- name: 'check-openssl'
  command: 'openssl'
  args: ['version']
  expectedOutput: ['OpenSSL .*']

fileExistenceTests:
- name: 'OpenJDK'
  path: '/usr/lib/jvm/java-8-openjdk-amd64'
  shouldExist: true
- name: 'OpenJDK 11'
  path: '/usr/lib/jvm/{_JAVA_REVISION}'
  shouldExist: true
- name: 'OpenJDK 11 srcs'
  path: '/usr/src/jdk/{_SRC_REVISION}.zip'
  shouldExist: true

metadataTest:
  env:
    - key: 'JAVA_HOME'
      value: '/usr/lib/jvm/java-8-openjdk-amd64'
