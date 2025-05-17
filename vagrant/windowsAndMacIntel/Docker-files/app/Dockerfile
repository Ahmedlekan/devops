# ----------------------
# Stage 1: Build with Maven
# ----------------------
FROM maven:3.9.9-eclipse-temurin-21 AS builder

# Install git (since it's not included in base image)
RUN apt-get update && \
    apt-get install -y git && \
    rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch containers https://github.com/Ahmedlekan/devops-project.git && \ 
cd vprofile-project && \ 
mvn clean package -DskipTests

# ----------------------
# Stage 2: Tomcat + deploy artifact
# ----------------------
FROM tomcat:10.1.20-jdk21

# Clean default webapps
RUN rm -rf /usr/local/tomcat/webapps/*

# Copy built WAR
COPY --from=builder vprofile-project/target/*vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

CMD ["catalina.sh", "run"]
