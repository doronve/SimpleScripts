CREATE TABLE env_secrets (
                              sequence_number SERIAL PRIMARY KEY,
                              secret_name VARCHAR(255),
                              secret_type VARCHAR(255),
                              secret_username VARCHAR(255),
                              secret_password VARCHAR(255),
                              destination_url VARCHAR(255),
                              keystore_file VARCHAR(255),
                              truststore_file VARCHAR(255),
                              keystore_password VARCHAR(255),
                              truststore_password VARCHAR(255)
);